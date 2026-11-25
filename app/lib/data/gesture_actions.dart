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
}
