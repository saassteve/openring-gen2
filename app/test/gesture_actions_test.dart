import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ring_protocol/ring_protocol.dart';
import 'package:ringconn_companion/data/gesture_actions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GestureActionConfig round-trips JSON encoding and defaults', () {
    const defaults = GestureActionConfig();
    expect(defaults.tapAction, RingDeviceAction.none);
    expect(defaults.doubleTapAction, RingDeviceAction.mediaPlayPause);
    expect(defaults.flickAction, RingDeviceAction.mediaNext);
    expect(defaults.usesAccessibility, isFalse);

    final custom = defaults.copyWith(
      sensitivity: GestureSensitivity.high,
      tapAction: RingDeviceAction.toggleFlashlight,
      doubleTapAction: RingDeviceAction.scrollDown,
      flickAction: RingDeviceAction.webhook,
      webhookUrl: 'http://homeassistant.local:8123/api/webhook/ring',
    );
    final decoded = GestureActionConfig.decode(custom.encode());
    expect(decoded.sensitivity, GestureSensitivity.high);
    expect(decoded.tapAction, RingDeviceAction.toggleFlashlight);
    expect(decoded.doubleTapAction, RingDeviceAction.scrollDown);
    expect(decoded.flickAction, RingDeviceAction.webhook);
    expect(decoded.webhookUrl, 'http://homeassistant.local:8123/api/webhook/ring');
    expect(decoded.usesAccessibility, isTrue);
    expect(decoded.usesWebhook, isTrue);
  });

  test('DeviceActionChannel invokes Android platform channel cleanly', () async {
    const channelName = 'ringconn/device_actions_test';
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), (call) async {
          calls.add(call);
          if (call.method == 'performAction') {
            return {'ok': true, 'detail': 'Play / Pause media'};
          }
          if (call.method == 'accessibilityStatus') return true;
          return true;
        });

    final actions = DeviceActionChannel(
      channel: const MethodChannel(channelName),
      supportedOverride: true,
    );
    final outcome = await actions.performAction(
      action: RingDeviceAction.mediaPlayPause,
      gesture: RingGesture.doubleTap,
      peakG: 0.62,
      haptic: true,
    );
    expect(outcome.ok, isTrue);
    expect(outcome.detail, 'Play / Pause media');
    expect(await actions.isAccessibilityEnabled(), isTrue);
    expect(calls.map((c) => c.method), ['performAction', 'accessibilityStatus']);
  });

  test('SmartAutomationConfig round-trips JSON encoding cleanly', () {
    const defaults = SmartAutomationConfig();
    expect(defaults.ringOffPauseMedia, isTrue);
    expect(defaults.ringOffReminderMinutes, 15);
    expect(defaults.lowBatteryGuardPercent, 20);
    expect(defaults.broadcastBiometrics, isTrue);

    final custom = defaults.copyWith(
      ringOffPauseMedia: false,
      ringOffReminderMinutes: 30,
      lowBatteryGuardPercent: 15,
      dozeOffPauseMedia: true,
      opticalTapAction: RingDeviceAction.toggleFlashlight,
      eventWebhookUrl: 'http://homeassistant.local:8123/api/webhook/events',
    );
    final decoded = SmartAutomationConfig.decode(custom.encode());
    expect(decoded.ringOffPauseMedia, isFalse);
    expect(decoded.ringOffReminderMinutes, 30);
    expect(decoded.lowBatteryGuardPercent, 15);
    expect(decoded.dozeOffPauseMedia, isTrue);
    expect(decoded.opticalTapAction, RingDeviceAction.toggleFlashlight);
    expect(
      decoded.eventWebhookUrl,
      'http://homeassistant.local:8123/api/webhook/events',
    );
  });
}
