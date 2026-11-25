import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:ring_protocol/ring_protocol.dart';

enum RingDeviceAction {
  none('Off', 'Ignore this gesture', requiresAccessibility: false),
  mediaPlayPause(
    'Play / Pause media',
    'Works across Spotify, YouTube, podcasts, even screen off',
    requiresAccessibility: false,
  ),
  mediaNext(
    'Next track',
    'Skip to next song or chapter (works screen off)',
    requiresAccessibility: false,
  ),
  mediaPrevious(
    'Previous track',
    'Return to previous track (works screen off)',
    requiresAccessibility: false,
  ),
  volumeUp(
    'Volume up / Camera shutter',
    'Raises media volume (triggers shutter in many camera apps)',
    requiresAccessibility: false,
  ),
  volumeDown(
    'Volume down',
    'Lowers media volume',
    requiresAccessibility: false,
  ),
  toggleFlashlight(
    'Toggle flashlight',
    'Switches rear camera LED torch on or off',
    requiresAccessibility: false,
  ),
  scrollDown(
    'Scroll down / Next video',
    'Swipes up in Reels, Shorts, TikTok, Reddit, or feeds',
    requiresAccessibility: true,
  ),
  scrollUp(
    'Scroll up / Previous',
    'Swipes down to scroll back up in any app',
    requiresAccessibility: true,
  ),
  nextPage(
    'Next page (swipe left)',
    'Turns pages in Kindle, galleries, or slides',
    requiresAccessibility: true,
  ),
  prevPage(
    'Previous page (swipe right)',
    'Goes back a page in Kindle, galleries, or slides',
    requiresAccessibility: true,
  ),
  screenshot(
    'Take screenshot',
    'Captures the current Android screen',
    requiresAccessibility: true,
  ),
  back(
    'Navigate back',
    'System back button across any app',
    requiresAccessibility: true,
  ),
  broadcast(
    'Android broadcast (Tasker)',
    'Sends com.ringcompanion.app.ACTION_RING_GESTURE',
    requiresAccessibility: false,
  ),
  webhook(
    'HTTP webhook (Home Assistant)',
    'POSTs JSON gesture payload to your custom URL',
    requiresAccessibility: false,
  );

  const RingDeviceAction(
    this.label,
    this.description, {
    required this.requiresAccessibility,
  });

  final String label;
  final String description;
  final bool requiresAccessibility;

  static RingDeviceAction parse(String? raw, RingDeviceAction fallback) {
    if (raw == null) return fallback;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return fallback;
  }
}

final class GestureActionConfig {
  const GestureActionConfig({
    this.sensitivity = GestureSensitivity.medium,
    this.actionsEnabled = true,
    this.backgroundService = true,
    this.hapticFeedback = true,
    this.tapAction = RingDeviceAction.none,
    this.doubleTapAction = RingDeviceAction.mediaPlayPause,
    this.flickAction = RingDeviceAction.mediaNext,
    this.webhookUrl = '',
  });

  final GestureSensitivity sensitivity;
  final bool actionsEnabled;
  final bool backgroundService;
  final bool hapticFeedback;
  final RingDeviceAction tapAction;
  final RingDeviceAction doubleTapAction;
  final RingDeviceAction flickAction;
  final String webhookUrl;

  RingDeviceAction actionFor(RingGesture gesture) => switch (gesture) {
    RingGesture.tap => tapAction,
    RingGesture.doubleTap => doubleTapAction,
    RingGesture.flick => flickAction,
  };

  bool get usesAccessibility =>
      tapAction.requiresAccessibility ||
      doubleTapAction.requiresAccessibility ||
      flickAction.requiresAccessibility;

  bool get usesWebhook =>
      tapAction == RingDeviceAction.webhook ||
      doubleTapAction == RingDeviceAction.webhook ||
      flickAction == RingDeviceAction.webhook;

  String get notificationSummary {
    final parts = <String>[];
    if (tapAction != RingDeviceAction.none) {
      parts.add('Tap: ${tapAction.label}');
    }
    if (doubleTapAction != RingDeviceAction.none) {
      parts.add('Double-tap: ${doubleTapAction.label}');
    }
    if (flickAction != RingDeviceAction.none) {
      parts.add('Flick: ${flickAction.label}');
    }
    return parts.isEmpty
        ? 'Listening for gestures'
        : parts.join(' · ');
  }

  GestureActionConfig copyWith({
    GestureSensitivity? sensitivity,
    bool? actionsEnabled,
    bool? backgroundService,
    bool? hapticFeedback,
    RingDeviceAction? tapAction,
    RingDeviceAction? doubleTapAction,
    RingDeviceAction? flickAction,
    String? webhookUrl,
  }) => GestureActionConfig(
    sensitivity: sensitivity ?? this.sensitivity,
    actionsEnabled: actionsEnabled ?? this.actionsEnabled,
    backgroundService: backgroundService ?? this.backgroundService,
    hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    tapAction: tapAction ?? this.tapAction,
    doubleTapAction: doubleTapAction ?? this.doubleTapAction,
    flickAction: flickAction ?? this.flickAction,
    webhookUrl: webhookUrl ?? this.webhookUrl,
  );

  String encode() => jsonEncode({
    'sensitivity': sensitivity.name,
    'actionsEnabled': actionsEnabled,
    'backgroundService': backgroundService,
    'hapticFeedback': hapticFeedback,
    'tapAction': tapAction.name,
    'doubleTapAction': doubleTapAction.name,
    'flickAction': flickAction.name,
    'webhookUrl': webhookUrl,
  });

  static GestureActionConfig decode(String? raw) {
    if (raw == null || raw.isEmpty) return const GestureActionConfig();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final sensName = map['sensitivity'] as String?;
      final sensitivity = GestureSensitivity.values.firstWhere(
        (s) => s.name == sensName,
        orElse: () => GestureSensitivity.medium,
      );
      return GestureActionConfig(
        sensitivity: sensitivity,
        actionsEnabled: map['actionsEnabled'] as bool? ?? true,
        backgroundService: map['backgroundService'] as bool? ?? true,
        hapticFeedback: map['hapticFeedback'] as bool? ?? true,
        tapAction: RingDeviceAction.parse(
          map['tapAction'] as String?,
          RingDeviceAction.none,
        ),
        doubleTapAction: RingDeviceAction.parse(
          map['doubleTapAction'] as String?,
          RingDeviceAction.mediaPlayPause,
        ),
        flickAction: RingDeviceAction.parse(
          map['flickAction'] as String?,
          RingDeviceAction.mediaNext,
        ),
        webhookUrl: map['webhookUrl'] as String? ?? '',
      );
    } catch (_) {
      return const GestureActionConfig();
    }
  }
}


final class SmartAutomationConfig {
  const SmartAutomationConfig({
    this.ringOffPauseMedia = true,
    this.ringOffReminderMinutes = 15,
    this.lowBatteryGuardPercent = 20,
    this.dozeOffPauseMedia = false,
    this.broadcastBiometrics = true,
    this.opticalTapAction = RingDeviceAction.mediaPlayPause,
    this.eventWebhookUrl = '',
  });

  /// Pause active media automatically when the ring is taken off finger.
  final bool ringOffPauseMedia;

  /// Minutes after ring-off (not charging) before notifying "Don't forget your ring" (0 = off).
  final int ringOffReminderMinutes;

  /// Notify once per discharge cycle when ring battery drops to/below this % (0 = off).
  final int lowBatteryGuardPercent;

  /// Pause media automatically when on-finger dual-NTC thermal delta signals sleep onset.
  final bool dozeOffPauseMedia;

  /// Broadcast live biometrics & wear/battery events via Android Intent for Tasker / KWGT.
  final bool broadcastBiometrics;

  /// Action triggered by a fast (~400 ms) optical cover-tap during live 0x12 PPG mode.
  final RingDeviceAction opticalTapAction;

  /// Optional webhook URL receiving ring_off, ring_on, low_battery, doze_off JSON payloads.
  final String eventWebhookUrl;

  SmartAutomationConfig copyWith({
    bool? ringOffPauseMedia,
    int? ringOffReminderMinutes,
    int? lowBatteryGuardPercent,
    bool? dozeOffPauseMedia,
    bool? broadcastBiometrics,
    RingDeviceAction? opticalTapAction,
    String? eventWebhookUrl,
  }) => SmartAutomationConfig(
    ringOffPauseMedia: ringOffPauseMedia ?? this.ringOffPauseMedia,
    ringOffReminderMinutes:
        ringOffReminderMinutes ?? this.ringOffReminderMinutes,
    lowBatteryGuardPercent:
        lowBatteryGuardPercent ?? this.lowBatteryGuardPercent,
    dozeOffPauseMedia: dozeOffPauseMedia ?? this.dozeOffPauseMedia,
    broadcastBiometrics: broadcastBiometrics ?? this.broadcastBiometrics,
    opticalTapAction: opticalTapAction ?? this.opticalTapAction,
    eventWebhookUrl: eventWebhookUrl ?? this.eventWebhookUrl,
  );

  String encode() => jsonEncode({
    'ringOffPauseMedia': ringOffPauseMedia,
    'ringOffReminderMinutes': ringOffReminderMinutes,
    'lowBatteryGuardPercent': lowBatteryGuardPercent,
    'dozeOffPauseMedia': dozeOffPauseMedia,
    'broadcastBiometrics': broadcastBiometrics,
    'opticalTapAction': opticalTapAction.name,
    'eventWebhookUrl': eventWebhookUrl,
  });

  static SmartAutomationConfig decode(String? raw) {
    if (raw == null || raw.isEmpty) return const SmartAutomationConfig();
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return SmartAutomationConfig(
        ringOffPauseMedia: map['ringOffPauseMedia'] as bool? ?? true,
        ringOffReminderMinutes: map['ringOffReminderMinutes'] as int? ?? 15,
        lowBatteryGuardPercent: map['lowBatteryGuardPercent'] as int? ?? 20,
        dozeOffPauseMedia: map['dozeOffPauseMedia'] as bool? ?? false,
        broadcastBiometrics: map['broadcastBiometrics'] as bool? ?? true,
        opticalTapAction: RingDeviceAction.parse(
          map['opticalTapAction'] as String?,
          RingDeviceAction.mediaPlayPause,
        ),
        eventWebhookUrl: map['eventWebhookUrl'] as String? ?? '',
      );
    } catch (_) {
      return const SmartAutomationConfig();
    }
  }
}

typedef DeviceActionOutcome = ({bool ok, String detail});

class DeviceActionChannel {
  DeviceActionChannel({
    MethodChannel? channel,
    this.supportedOverride,
  }) : _channel = channel ?? const MethodChannel('ringconn/device_actions');

  final MethodChannel _channel;
  final bool? supportedOverride;

  bool get supported => supportedOverride ?? Platform.isAndroid;

  void setStopFromNotificationHandler(Future<void> Function() onStop) {
    if (!supported) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'stopGesturesFromNotification') {
        await onStop();
      }
    });
  }

  void dispose() {
    if (!supported) return;
    _channel.setMethodCallHandler(null);
  }

  Future<DeviceActionOutcome> performAction({
    required RingDeviceAction action,
    required RingGesture gesture,
    required double peakG,
    required bool haptic,
    String webhookUrl = '',
  }) async {
    if (action == RingDeviceAction.none) {
      return (ok: true, detail: 'No action');
    }
    if (!supported) {
      return (
        ok: false,
        detail: 'System-wide device actions are currently Android-only',
      );
    }
    try {
      final raw = await _channel.invokeMapMethod<String, Object?>(
        'performAction',
        {
          'action': action.name,
          'gesture': gesture.name,
          'peakG': peakG,
          'haptic': haptic,
          'webhookUrl': webhookUrl,
        },
      );
      return (
        ok: raw?['ok'] as bool? ?? false,
        detail: raw?['detail'] as String? ?? action.label,
      );
    } on MissingPluginException {
      return (ok: false, detail: 'Device action channel unavailable');
    } on PlatformException catch (error) {
      return (ok: false, detail: error.message ?? error.code);
    }
  }

  Future<void> setBackgroundService({
    required bool active,
    required String summary,
  }) async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<bool>('setBackgroundService', {
        'active': active,
        'summary': summary,
      });
    } on MissingPluginException {
      // Ignore in widget tests without Android platform channel.
    } on PlatformException {
      // Non-fatal if OS rejects foreground service start.
    }
  }

  Future<bool> isAccessibilityEnabled() async {
    if (!supported) return false;
    try {
      return await _channel.invokeMethod<bool>('accessibilityStatus') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<void>('openAccessibilitySettings');
    } on MissingPluginException {
      // Ignore in tests.
    }
  }

  Future<void> notifyAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<bool>('notifyAlert', {
        'id': id,
        'title': title,
        'body': body,
      });
    } on MissingPluginException {
      // Ignore in tests.
    } on PlatformException {
      // Non-fatal.
    }
  }

  Future<void> cancelAlert(int id) async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<bool>('cancelAlert', {'id': id});
    } on MissingPluginException {
      // Ignore in tests.
    } on PlatformException {
      // Non-fatal.
    }
  }

  Future<void> broadcastEvent({
    required String event,
    required String detail,
    Map<String, Object?> extras = const {},
    String webhookUrl = '',
  }) async {
    if (!supported) return;
    try {
      await _channel.invokeMethod<bool>('broadcastEvent', {
        'event': event,
        'detail': detail,
        'extras': extras,
        'webhookUrl': webhookUrl,
      });
    } on MissingPluginException {
      // Ignore in tests.
    } on PlatformException {
      // Non-fatal.
    }
  }
}
