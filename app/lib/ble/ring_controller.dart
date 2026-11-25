import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:path_provider/path_provider.dart';
import 'package:ring_protocol/ring_protocol.dart';

import '../data/health_exporter.dart';
import '../data/ring_database.dart';
import 'command_console.dart';
import 'ring_ble.dart';

enum LinkState {
  disconnected,
  scanning,
  connecting,
  subscribing,
  authenticating,
  ready,
}

typedef NearbyRing = ({String id, String name, int rssi, String? source});
typedef HeartRatePoint = ({DateTime time, int bpm});

final class RingController extends ChangeNotifier {
  RingController(
    this.database, {
    this._ble = const RingBle(),
    HealthExporter? healthExporter,
  }) : healthExporter = healthExporter ?? HealthExporter(database) {
    _subscription = _ble.events.listen(
      _event,
      onError: (Object error) {
        unawaited(_enqueue(() async => throw error));
      },
    );
    unawaited(
      _enqueue(() async {
        autoHealthExport = await database.getAutoHealthExport();
        final last = await database.latestDevice();
        if (last != null) _loadDevice(last.id, last.name, last.firmware);
      }),
    );
  }

  final RingDatabase database;
  final RingBle _ble;
  final HealthExporter healthExporter;
  final FrameReassembler _parser = FrameReassembler();
  final Map<String, NearbyRing> _nearby = {};
  final List<HeartRatePoint> _heartRate = [];
  final Stopwatch _traceClock = Stopwatch();
  late final StreamSubscription<Map<Object?, Object?>> _subscription;
  Future<void> _work = Future.value();
  Timer? _bulkTimer;
  Timer? _authTimer;
  Timer? _pollTimer;
  Timer? _historyTimer;
  bool _pollQueued = false;
  bool _disposed = false;
  NearbyRing? _selected;
  Uint8List? _identity;
  String? _deviceId;
  int? _connection;
  int? _lastChallenge;
  int? _drainSession;
  DateTime? _latestDescriptorAt;
  bool _sessionInitialized = false;
  FrameReassembler? _commandParser;
  CommandScan? _commandScan;
  late final commandLog = CommandLog(onChanged: _publish);

  LinkState state = LinkState.disconnected;
  String? message;
  String? bond;
  String? name;
  String? firmware;
  int? writeLimit;
  AuthStatus? authStatus;
  TelemetryFrame? telemetry;
  RingMode mode = RingMode.idle;
  final Map<RingParam, int> paramValues = {};
  final Map<RingParam, int> _pendingParamValues = {};
  RingParam? pendingParam;
  HistoryDrain? drain;
  String? drainDetail;
  final PpgBiofeedbackAnalyzer ppgAnalyzer = PpgBiofeedbackAnalyzer();
  final GestureDetector3D gestureDetector = GestureDetector3D();
  bool accStreaming = false;
  TemperatureReply? sensorTemperature;
  bool autoHealthExport = true;
  bool healthExporting = false;
  String? healthExportStatus;
  bool healthNeedsPermission = false;

  Future<void> setAutoHealthExport(bool enabled) async {
    autoHealthExport = enabled;
    await database.setAutoHealthExport(enabled);
    _publish();
  }
  Stream<List<TelemetrySnapshot>>? batteryHistory;
  Stream<DrainSession?>? drainHistory;

  bool get connected => state == LinkState.ready;
  bool get measuring => mode == RingMode.heartRate;
  bool get ppgStreaming => mode == RingMode.densePpg;
  bool get syncing => drain != null && !drain!.finished;
  String? get deviceId => _deviceId;
  List<NearbyRing> get nearby {
    int rank(String? source) => switch (source) {
      'connected' => 0,
      'bonded' => 2,
      _ => 1,
    };
    return _nearby.values.toList()..sort((a, b) {
      final byRank = rank(a.source).compareTo(rank(b.source));
      return byRank != 0 ? byRank : b.rssi.compareTo(a.rssi);
    });
  }
  List<HeartRatePoint> get heartRate => List.unmodifiable(_heartRate);
  int get discardedBytes => _parser.discardedBytes;
  bool get canSendCommands =>
      connected && !syncing && mode == RingMode.idle && !accStreaming;
  bool get scanningCommands => _commandScan != null;

  void openCommandConsole() {
    _commandParser ??= FrameReassembler();
    unawaited(commandLog.load());
  }

  void closeCommandConsole() {
    _commandParser = null;
    stopCommandScan();
  }

  Future<void> sendCommand(Uint8List bytes) => _enqueue(() async {
    if (_commandParser == null || scanningCommands) return;
    await _writeConsole(bytes);
  });

  Future<void> scanCommands(List<int> opcodes) async {
    if (_commandParser == null || !canSendCommands || scanningCommands) return;
    if (opcodes.isEmpty ||
        opcodes.length > maxScanCommands ||
        opcodes.any((opcode) => opcode < 0 || opcode > 0xff)) {
      throw ArgumentError('A scan takes 1 to $maxScanCommands byte opcodes.');
    }
    final connection = _connection;
    final scan = _commandScan = CommandScan();
    final commands = List<int>.of(opcodes);
    final acknowledged = <int>[];
    var completed = 0;
    _logCommand('Scan started (${commands.length} opcodes)');
    _publish();
    try {
      for (final opcode in commands) {
        var sent = false;
        await _enqueue(() async {
          if (_connection != connection || scan.stopped) return;
          scan.expect(opcode);
          sent = await _writeConsole(Uint8List.fromList([opcode, 0, 0]));
        });
        if (!sent) break;
        final ack = await scan.waitForAck();
        if (ack == null) break;
        completed++;
        if (ack) acknowledged.add(opcode);
        final expected = commandHex([opcode ^ 0x80]);
        _logCommand(
          'Scan 0x${commandHex([opcode])} • '
          '${ack ? 'ACK 0x$expected' : 'no ACK (expected 0x$expected)'}',
        );
      }
    } finally {
      final hits = acknowledged
          .map((opcode) => '0x${commandHex([opcode])}')
          .join(', ');
      _logCommand(
        'Scan ${completed == commands.length ? 'finished' : 'stopped'}'
        ' • ${acknowledged.length} ACKs • $completed/${commands.length} checked'
        '${hits.isEmpty ? '' : ' • $hits'}',
      );
      _commandScan = null;
      _publish();
    }
  }

  void stopCommandScan() => _commandScan?.stop();

  Future<bool> _writeConsole(Uint8List bytes) async {
    if (!canSendCommands) {
      _logCommand('Send unavailable. Connect to an idle ring first.');
      return false;
    }
    final limit = writeLimit;
    if (bytes.isEmpty || (limit != null && bytes.length > limit)) {
      _logCommand('Send rejected. Enter 1 to ${limit ?? 0} bytes.');
      return false;
    }
    try {
      await _send(bytes);
      return true;
    } catch (error) {
      final detail = error is PlatformException
          ? error.message ?? error.code
          : error;
      _logCommand('Write failed • $detail');
      return false;
    }
  }

  void _logCommand(String text) => commandLog.add(DateTime.now(), text);

  FrameObserver? _commandObserver(DateTime time) {
    if (_commandParser == null) return null;
    return (bytes, frame) {
      _commandScan?.observe(bytes.first);
      commandLog.add(
        time,
        'RX ${commandFrameSummary(bytes, frame)} • ${commandHex(bytes)}',
      );
    };
  }

  Future<void> scan() => _enqueue(() async {
    if (state != LinkState.disconnected) return;
    message = null;
    _nearby.clear();
    state = LinkState.scanning;
    _publish();
    await _ble.startScan();
  });

  Future<void> stopScan() => _enqueue(() async {
    if (state != LinkState.scanning) return;
    await _ble.stopScan();
    state = LinkState.disconnected;
  });

  Future<void> connect(NearbyRing ring) => _enqueue(() async {
    if (state != LinkState.scanning && state != LinkState.disconnected) return;
    _selected = ring;
    message = null;
    telemetry = null;
    drain = null;
    drainDetail = null;
    _heartRate.clear();
    state = LinkState.connecting;
    _publish();
    await _ble.connect(ring.id);
  });

  Future<void> disconnect() => _enqueue(() async {
    if (_selected == null) return;
    try {
      if (connected && !syncing && (mode != RingMode.idle || accStreaming)) {
        await _send(RingCommands.mode(RingMode.idle));
      }
    } finally {
      if (syncing) {
        drain!.cancel();
        await _finishDrain('Disconnected by the user.');
      }
      await _ble.disconnect();
      _resetLink();
    }
  });

  Future<void> setHeartRate(bool enabled) => _enqueue(() async {
    if (!connected || syncing || measuring == enabled) return;
    _pollTimer?.cancel();
    if (enabled) {
      if (accStreaming) {
        await _send(RingCommands.mode(RingMode.idle));
        accStreaming = false;
      }
      await _initSession();
      _heartRate.clear();
    }
    final target = enabled ? RingMode.heartRate : RingMode.idle;
    await _send(RingCommands.mode(target));
    mode = target;
    await _send(RingCommands.telemetry());
    _startPolling();
  });

  Future<void> setDensePpg(bool enabled) => _enqueue(() async {
    if (!connected || syncing || ppgStreaming == enabled) return;
    _pollTimer?.cancel();
    if (enabled) {
      if (accStreaming || mode != RingMode.idle) {
        await _send(RingCommands.mode(RingMode.idle));
        accStreaming = false;
      }
      await _initSession();
      ppgAnalyzer.reset();
      await _send(RingCommands.mode(RingMode.densePpg));
      mode = RingMode.densePpg;
    } else {
      await _send(RingCommands.mode(RingMode.idle));
      mode = RingMode.idle;
      await _send(RingCommands.telemetry());
      _startPolling();
    }
  });

  Future<void> setAccelerometer(bool enabled) => _enqueue(() async {
    if (!connected || syncing || accStreaming == enabled) return;
    _pollTimer?.cancel();
    if (enabled) {
      if (mode != RingMode.idle) {
        await _send(RingCommands.mode(RingMode.idle));
        mode = RingMode.idle;
      }
      gestureDetector.reset();
      await _send(RingCommands.startAccelerometer());
      accStreaming = true;
    } else {
      await _send(RingCommands.mode(RingMode.idle));
      accStreaming = false;
      await _send(RingCommands.telemetry());
      _startPolling();
    }
  });

  Future<void> readSensorTemperature() => _enqueue(() async {
    if (!connected || syncing) return;
    await _send(RingCommands.readTemperature());
  });

  Future<void> forceStopModes() => _enqueue(() async {
    if (!connected || syncing) return;
    await _send(RingCommands.mode(RingMode.idle));
    mode = RingMode.idle;
    accStreaming = false;
    await _send(RingCommands.telemetry());
    _startPolling();
  });

  int? paramValue(RingParam param) => paramValues[param];

  Future<void> setRingParam(RingParam param, int value) => _enqueue(() async {
    if (!canSendCommands || pendingParam != null) return;
    message = null;
    pendingParam = param;
    _pendingParamValues[param] = value;
    _publish();
    await _send(RingCommands.setParam(param, value));
  });

  Future<void> syncHistory() => _enqueue(() async {
    if (!connected || syncing) return;
    _pollTimer?.cancel();
    if (mode != RingMode.idle) {
      await _send(RingCommands.mode(RingMode.idle));
      mode = RingMode.idle;
    }
    final now = DateTime.now();
    final history = HistoryDrain(cursor: cursorFromTime(now));
    final open = history.start();
    _drainSession = await database.openDrain(_deviceId!, history, now);
    drain = history;
    drainDetail = null;
    _publish();
    await _initSession();
    await _send(open);
    _watchDrain(history);
  });

  Future<void> cancelSync() => _enqueue(() async {
    if (!syncing) return;
    drain!.cancel();
    await _finishDrain(
      'Sync stopped. Pages already saved remain on this phone.',
    );
    // Closing the link terminates an outstanding drain without ACKing more pages.
    await _ble.disconnect();
    _resetLink();
  });

  void _event(Map<Object?, Object?> event) {
    final receivedAt = DateTime.now();
    final elapsed = _traceClock.elapsedMilliseconds;
    unawaited(
      _enqueue(() async {
        switch (event['type']) {
          case 'scan':
            if (event['active'] == false && state == LinkState.scanning) {
              state = LinkState.disconnected;
            }
          case 'device':
            if (state != LinkState.scanning) return;
            final id = event['id'] as String;
            final source = event['source'] as String?;
            final prev = _nearby[id];
            _nearby[id] = (
              id: id,
              name: event['name'] as String,
              rssi: event['rssi'] as int,
              source:
                  source ??
                  (prev?.source == 'connected' ? 'connected' : null),
            );
          case 'ready':
            if (state == LinkState.connecting && _selected?.id == event['id']) {
              await _subscribe(event, receivedAt);
            }
          case 'bond':
            if (_selected != null) bond = event['state'] as String;
          case 'notification':
            if (_connection == null) return;
            final bytes = event['bytes'] as Uint8List;
            await _savePacket('rx', bytes, elapsed);
            _bulkTimer?.cancel();
            final commandParser = _commandParser;
            final observe = _commandObserver(receivedAt);
            commandParser?.add(bytes, observe: observe);
            await _handleFrames(_parser.add(bytes), receivedAt);
            final connection = _connection;
            if (_parser.hasPendingBytes ||
                commandParser?.hasPendingBytes == true) {
              _bulkTimer = Timer(FrameReassembler.bulkQuietPeriod, () {
                unawaited(
                  _enqueue(() async {
                    if (_connection != connection) return;
                    if (identical(_commandParser, commandParser)) {
                      commandParser?.flush(observe: observe);
                    }
                    await _handleFrames(_parser.flush(), receivedAt);
                  }),
                );
              });
            }
          case 'error':
            message = event['message'] as String;
            if (state == LinkState.scanning) state = LinkState.disconnected;
          case 'disconnected':
            if (_selected != null) {
              final reason = event['reason'] as String;
              _resetLink();
              message ??= reason;
              await _interruptDrain(reason);
            }
        }
      }),
    );
  }

  Future<void> _subscribe(Map<Object?, Object?> event, DateTime time) async {
    final ring = _selected!;
    final systemId = event['systemId'] as Uint8List;
    final identity = identityFromSystemId(systemId, ring.name);
    if (identity == null) {
      throw const FormatException(
        'Ring System ID does not match its advertised name.',
      );
    }
    final deviceId = commandHex(identity);
    final version = event['firmware'] as String?;
    await database.rememberDevice(
      DevicesCompanion.insert(
        id: deviceId,
        platformId: ring.id,
        name: ring.name,
        firmware: Value(version),
        serial: Value(event['serial'] as String?),
        systemId: systemId,
        lastSeenAt: time,
      ),
    );
    _loadDevice(deviceId, ring.name, version);
    _identity = identity;
    writeLimit = event['writeLimit'] as int;
    _connection = time.microsecondsSinceEpoch;
    _traceClock
      ..reset()
      ..start();
    state = LinkState.subscribing;
    _publish();
    await _ble.subscribe();
    state = LinkState.authenticating;
    _publish();
    await _send(RingCommands.status());
    final connection = _connection;
    _authTimer = Timer(const Duration(seconds: 10), () {
      unawaited(
        _enqueue(() async {
          if (_connection == connection && state == LinkState.authenticating) {
            throw TimeoutException('The ring did not confirm authentication.');
          }
        }),
      );
    });
  }

  Future<void> _handleFrames(List<RingFrame> frames, DateTime time) async {
    for (final frame in frames) {
      switch (frame) {
        case AuthChallenge():
          if (state == LinkState.authenticating &&
              _lastChallenge != frame.challenge) {
            _lastChallenge = frame.challenge;
            await _send(RingCommands.authenticate(_identity!, frame.challenge));
          }
        case AuthStatus():
          if (state == LinkState.authenticating && _lastChallenge != null) {
            if (!frame.accepted) {
              throw StateError('The ring declined authentication.');
            }
            _authTimer?.cancel();
            authStatus = frame;
            paramValues[RingParam.autoSports] = frame.sportsMonitor ? 1 : 0;
            paramValues[RingParam.osaPlan] = frame.monitorPlanStatus;
            state = LinkState.ready;
            await _send(RingCommands.telemetry());
            _startPolling();
          }
        case SetParamReply():
          final param = frame.param ?? pendingParam;
          if (param != null) {
            final requested = _pendingParamValues.remove(param);
            if (pendingParam == param) pendingParam = null;
            if (frame.accepted) {
              if (requested != null) paramValues[param] = requested;
              message = '${param.label} updated.';
            } else {
              message =
                  'The ring rejected ${param.label} (status ${frame.status}).';
            }
          }
        case TelemetryFrame():
          if (!connected) continue;
          await database.saveTelemetry(_deviceId!, time, frame);
          telemetry = frame;
          _latestDescriptorAt = time;
        case LiveHeartRateFrame():
          if (!connected) continue;
          await database.saveHeartRate(_deviceId!, time, frame);
          final bpm = frame.bpm;
          if (measuring && bpm != null) {
            _heartRate.add((time: time, bpm: bpm));
            if (_heartRate.length > 60) _heartRate.removeAt(0);
          }
        case ModeReply():
          if (connected && !frame.accepted) {
            message = 'The ring rejected the mode command.';
            mode = RingMode.idle;
            _startPolling();
          }
        case StatusNotice():
          if (connected) await _send(RingCommands.acknowledgeStatus());
        case HistoryOpened():
          if (syncing && !frame.accepted) {
            drain!.fail();
            await _finishDrain('The ring rejected the history request.');
            _startPolling();
          }
        case HistoryPage():
          if (syncing) await _persistAndAcknowledge(frame, time);
        case AccStreamReply():
          if (connected && !frame.accepted) {
            message = 'The ring rejected the accelerometer command.';
            accStreaming = false;
            _startPolling();
          }
        case TemperatureReply():
          sensorTemperature = frame;
        case DensePpgFrame():
          ppgAnalyzer.addFrame(frame);
        case RawPpgFrame():
          gestureDetector.addFrame(frame);
      }
    }
  }

  Future<void> _persistAndAcknowledge(HistoryPage page, DateTime time) async {
    _historyTimer?.cancel();
    final history = drain!;
    final session = _drainSession!;
    final deviceId = _deviceId!;
    history.pageReceived(page);
    final pageId = await database.savePage(session, deviceId, page, time);
    await _send(history.pagePersisted());
    history.acknowledged();
    await database.confirmPage(
      pageId: pageId,
      sessionId: session,
      deviceId: deviceId,
      page: page,
      drain: history,
      time: DateTime.now(),
    );
    if (history.finished) {
      await _finishDrain(null);
      _startPolling();
    } else {
      _watchDrain(history);
    }
  }

  void _watchDrain(HistoryDrain history) {
    _historyTimer?.cancel();
    _historyTimer = Timer(const Duration(seconds: 6), () {
      unawaited(
        _enqueue(() async {
          if (drain != history || history.phase != DrainPhase.waiting) return;
          final retry = history.stalled();
          if (retry != null) {
            _parser.discardPending();
            await _send(retry);
            _watchDrain(history);
          } else {
            await _finishDrain(
              history.phase == DrainPhase.partial
                  ? 'Saved the pages received. The ring did not confirm both streams were empty.'
                  : 'The ring sent no history pages. Check the official app for backlog.',
            );
            // Drop the history session so late pages do not race with telemetry polling.
            await _ble.disconnect();
            _resetLink();
          }
        }),
      );
    });
  }

  Future<void> _finishDrain(String? detail) async {
    _historyTimer?.cancel();
    drainDetail = detail;
    final phase = drain?.phase;
    final session = _drainSession;
    if (session != null) {
      await database.closeDrain(session, drain!, detail);
      _drainSession = null;
    }
    if (HealthExporter.supportedPlatform &&
        (phase == DrainPhase.complete || phase == DrainPhase.partial) &&
        await database.getAutoHealthExport()) {
      unawaited(exportToHealthConnect(interactive: false));
    }
  }

  /// Exports pending local history to Android Health Connect.
  ///
  /// Automatic post-sync calls pass [interactive] = `false` so no permission
  /// dialog interrupts the user; if permissions have not been granted yet,
  /// [healthNeedsPermission] becomes `true` for a one-tap setup prompt.
  Future<void> exportToHealthConnect({bool interactive = true}) async {
    if (!HealthExporter.supportedPlatform || _disposed) return;
    healthExporting = true;
    healthExportStatus = interactive
        ? 'Exporting to Android Health Connect…'
        : 'Auto-exporting to Android Health Connect…';
    _publish();
    try {
      final result = await healthExporter.export(interactive: interactive);
      if (_disposed) return;
      final total = result.counts.values.fold(0, (sum, n) => sum + n);
      healthNeedsPermission =
          result.granted.isEmpty && result.denied.isNotEmpty;
      if (healthNeedsPermission) {
        healthExportStatus =
            'Android Health Connect permission needed for auto-export.';
      } else if (total > 0) {
        final summary = [
          for (final entry in result.counts.entries)
            '${entry.key.label} ${entry.value}',
        ].join(' · ');
        healthExportStatus = interactive
            ? 'Exported $total records to Health Connect ($summary).'
            : 'Auto-exported $total records to Health Connect ($summary).';
      } else if (result.failures.isNotEmpty) {
        healthExportStatus =
            'Health Connect export partial: ${result.failures.values.first}';
      } else if (result.granted.isNotEmpty) {
        healthExportStatus = 'Android Health Connect is up to date.';
      } else {
        healthExportStatus =
            'Android Health Connect is unavailable on this device.';
      }
    } on PlatformException catch (error) {
      if (_disposed) return;
      healthNeedsPermission = error.code == 'permission_denied';
      healthExportStatus =
          error.message ?? 'Could not export to Android Health Connect.';
    } catch (error) {
      if (_disposed) return;
      healthExportStatus = 'Could not export to Android Health Connect. $error';
    } finally {
      healthExporting = false;
      _publish();
    }
  }

  Future<void> _interruptDrain(String detail) async {
    if (_drainSession != null) {
      final history = drain!;
      history.fail();
      await _finishDrain(detail);
    }
  }

  Future<void> _initSession() async {
    if (_sessionInitialized) return;
    await _send(RingCommands.sessionInit());
    _sessionInitialized = true;
  }

  void _startPolling() {
    _pollTimer?.cancel();
    if (!connected || syncing) return;
    final connection = _connection;
    final cadence = measuring
        ? const Duration(seconds: 2)
        : const Duration(seconds: 60);
    _pollTimer = Timer.periodic(cadence, (_) {
      if (_pollQueued) return;
      _pollQueued = true;
      unawaited(
        _enqueue(() async {
          if (!connected ||
              syncing ||
              scanningCommands ||
              _connection != connection) {
            return;
          }
          if (measuring) await _send(RingCommands.pollHeartRate());
          final last = _latestDescriptorAt;
          if (!measuring ||
              last == null ||
              DateTime.now().difference(last) >= const Duration(minutes: 1)) {
            await _send(RingCommands.telemetry());
          }
        }).whenComplete(() => _pollQueued = false),
      );
    });
  }

  Future<void> _send(Uint8List bytes) async {
    if (_commandParser != null) _logCommand('TX ${commandHex(bytes)}');
    await _savePacket('tx', bytes, _traceClock.elapsedMilliseconds);
    await _ble.write(bytes);
  }

  Future<void> _savePacket(String direction, Uint8List bytes, int elapsed) =>
      database.savePacket(
        deviceId: _deviceId!,
        connection: _connection!,
        direction: direction,
        elapsedMs: elapsed,
        bytes: bytes,
      );

  void _loadDevice(String deviceId, String deviceName, String? version) {
    if (_deviceId != deviceId) {
      batteryHistory = database.watchBattery(deviceId);
      drainHistory = database.watchLastDrain(deviceId);
    }
    _deviceId = deviceId;
    name = deviceName;
    firmware = version;
  }

  void _resetLink() {
    stopCommandScan();
    _authTimer?.cancel();
    _pollTimer?.cancel();
    _bulkTimer?.cancel();
    _historyTimer?.cancel();
    _parser.reset();
    _commandParser?.reset();
    _traceClock.stop();
    _sessionInitialized = false;
    _lastChallenge = null;
    _latestDescriptorAt = null;
    _connection = null;
    _selected = null;
    _identity = null;
    authStatus = null;
    paramValues.clear();
    _pendingParamValues.clear();
    pendingParam = null;
    writeLimit = null;
    bond = null;
    mode = RingMode.idle;
    accStreaming = false;
    state = LinkState.disconnected;
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    _work = _work.then((_) async {
      if (_disposed) return;
      try {
        await operation();
      } catch (error) {
        message = error is PlatformException
            ? error.message ?? error.code
            : error.toString();
        try {
          await _interruptDrain(message!);
        } catch (storageError) {
          message = '$message • $storageError';
        }
        if (_selected != null) {
          try {
            await _ble.disconnect();
          } catch (disconnectError) {
            debugPrint('BLE disconnect failed: $disconnectError');
          }
        }
        _resetLink();
      } finally {
        _publish();
      }
    });
    return _work;
  }

  Future<File?> exportTrace() async {
    final connection = await database.latestTraceConnection();
    if (connection == null) return null;
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/ringconn-$connection.jsonl');
    final output = file.openWrite();
    try {
      await for (final packet in database.tracePackets(connection)) {
        output.writeln(
          jsonEncode({
            't_ms': packet.elapsedMs,
            'dir': packet.direction,
            'len': packet.raw.length,
            'hex': commandHex(packet.raw),
          }),
        );
      }
      await output.flush();
    } finally {
      await output.close();
    }
    return file;
  }

  void _publish() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _resetLink();
    unawaited(_subscription.cancel());
    unawaited(_work.whenComplete(database.close));
    super.dispose();
  }
}
