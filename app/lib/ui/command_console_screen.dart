import 'package:material_ui/material_ui.dart';
import 'package:share_plus/share_plus.dart';

import '../ble/command_console.dart';
import '../ble/ring_controller.dart';

class CommandConsoleScreen extends StatefulWidget {
  const CommandConsoleScreen(this.ring, {super.key});

  final RingController ring;

  @override
  State<CommandConsoleScreen> createState() => _CommandConsoleScreenState();
}

class _CommandConsoleScreenState extends State<CommandConsoleScreen> {
  final _command = TextEditingController();
  final _opcodes = TextEditingController();
  late final AppLifecycleListener _lifecycle;
  String? _commandError;
  String? _scanError;
  bool _sending = false;

  RingController get _ring => widget.ring;

  @override
  void initState() {
    super.initState();
    _ring.openCommandConsole();
    _lifecycle = AppLifecycleListener(onPause: _ring.stopCommandScan);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _ring.closeCommandConsole();
    _command.dispose();
    _opcodes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _ring,
    builder: (context, _) {
      final enabled =
          _ring.canSendCommands && !_ring.scanningCommands && !_sending;
      final log = _ring.commandLog.recent.reversed.toList(growable: false);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Command console'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.ios_share),
                tooltip: 'Share command log',
                onPressed: () => _share(context),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!_ring.canSendCommands)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text('Connect to an idle ring to send commands.'),
                ),
              TextField(
                controller: _command,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Hex command',
                  hintText: '030000',
                  errorText: _commandError,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: enabled ? (_) => _send() : null,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: enabled ? _send : null,
                child: const Text('Send'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _opcodes,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: 'Scan opcodes',
                  hintText: '03, 06, 07',
                  helperText: 'Up to 120 hex opcodes, one per second.',
                  errorText: _scanError,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _ring.scanningCommands
                    ? _ring.stopCommandScan
                    : enabled
                    ? _scan
                    : null,
                child: Text(_ring.scanningCommands ? 'Stop scan' : 'Scan'),
              ),
              const Divider(height: 32),
              Text(
                'Command log',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (_ring.commandLog.error case final error?) Text(error),
              if (log.isEmpty)
                const Text('No commands or responses logged yet.'),
              for (final line in log)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SelectableText(
                    line,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );

  Future<void> _send() async {
    try {
      final bytes = parseCommandHex(_command.text);
      if (_ring.writeLimit case final limit? when bytes.length > limit) {
        throw FormatException(
          'The ring accepts at most $limit bytes per write.',
        );
      }
      setState(() {
        _commandError = null;
        _sending = true;
      });
      await _ring.sendCommand(bytes);
    } on FormatException catch (error) {
      if (mounted) setState(() => _commandError = error.message);
    } finally {
      if (mounted && _sending) setState(() => _sending = false);
    }
  }

  Future<void> _scan() async {
    try {
      final opcodes = parseScanOpcodes(_opcodes.text);
      setState(() => _scanError = null);
      await _ring.scanCommands(opcodes);
    } on FormatException catch (error) {
      if (mounted) setState(() => _scanError = error.message);
    }
  }

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox;
    final origin = box.localToGlobal(Offset.zero) & box.size;
    try {
      final file = await _ring.commandLog.shareFile();
      if (!context.mounted) return;
      if (file == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No command log to share yet.')),
        );
        return;
      }
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/plain')],
          sharePositionOrigin: origin,
        ),
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share command log. $error')),
        );
      }
    }
  }
}
