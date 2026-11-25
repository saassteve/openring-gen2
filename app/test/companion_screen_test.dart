import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:ringconn_companion/ble/ring_controller.dart';
import 'package:ringconn_companion/data/health_exporter.dart';
import 'package:ringconn_companion/data/ring_database.dart';
import 'package:ringconn_companion/ui/companion_screen.dart';

void main() {
  testWidgets('live, history, battery and diagnostics fit a narrow phone', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 690);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('ringconn/ble/events'),
      (_) async => null,
    );
    final controller = RingController(RingDatabase(NativeDatabase.memory()));
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: CompanionScreen()),
      ),
    );
    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.text('Live heart rate'), findsOneWidget);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sync the official app first'), findsOneWidget);

    await tester.tap(find.text('Battery'));
    await tester.pumpAndSettle();
    expect(
      find.text('Battery readings appear after the ring connects.'),
      findsOneWidget,
    );
    expect(find.text('Power & background monitors'), findsOneWidget);
    expect(find.text('Auto-sports monitor'), findsOneWidget);

    await tester.tap(find.text('Sensors'));
    await tester.pumpAndSettle();
    expect(find.text('PPG Biofeedback & Breathing'), findsOneWidget);
    expect(find.text('25 Hz Motion & Finger Gestures'), findsOneWidget);
    expect(find.text('System-Wide Device Control'), findsOneWidget);
    expect(find.text('Dual-NTC Thermal Gradient'), findsOneWidget);
    expect(find.text('Hidden History: Light, Thermal & HRV'), findsOneWidget);

    await tester.tap(find.byTooltip('Diagnostics'));
    await tester.pumpAndSettle();
    expect(find.text('Force-stop modes'), findsOneWidget);
    expect(find.text('Export raw trace'), findsOneWidget);
    await tester.tap(find.text('Command console'));
    await tester.pumpAndSettle();
    expect(find.text('Hex command'), findsOneWidget);
    expect(find.text('Scan opcodes'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Send'))
          .onPressed,
      isNull,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Health Connect (Android)'), findsOneWidget);
    expect(find.text('Android only'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android UI exposes auto-export switch and History status', (
    tester,
  ) async {
    HealthExporter.supportedPlatformOverride = true;
    addTearDown(() => HealthExporter.supportedPlatformOverride = null);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('ringconn/ble/events'),
      (_) async => null,
    );
    final controller = RingController(RingDatabase(NativeDatabase.memory()));
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: CompanionScreen()),
      ),
    );

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(
      find.text('Auto-export to Android Health Connect is on.'),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Health Connect (Android)'), findsOneWidget);
    expect(find.text('Auto-export after history sync'), findsOneWidget);
    expect(find.text('Sync to Health Connect now'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
