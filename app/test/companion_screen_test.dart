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
  test('friendlyRingName strips vendor names into clean consumer labels', () {
    expect(friendlyRingName(null), 'Smart Ring');
    expect(friendlyRingName(''), 'Smart Ring');
    expect(friendlyRingName('RingConn Gen2-03ad'), 'Smart Ring • 03AD');
    expect(friendlyRingName('RingConn Gen2'), 'Smart Ring');
    expect(friendlyRingName('My Titan Ring'), 'Smart Ring');
  });

  testWidgets('Home, Control, Wellness, Ring and Diagnostics fit a narrow phone', (
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
    expect(find.text('RingPilot'), findsOneWidget);
    expect(find.text('Smart Ring'), findsOneWidget);
    expect(find.text('Not connected'), findsOneWidget);
    expect(find.text('Ring Gestures'), findsOneWidget);
    expect(find.text('Live heart rate'), findsOneWidget);
    expect(find.textContaining('RingConn'), findsNothing);

    await tester.tap(find.text('Control'));
    await tester.pumpAndSettle();
    expect(find.text('Ring Control'), findsOneWidget);
    expect(find.text('Hands-Free Automations'), findsOneWidget);
    expect(find.text('Music & Podcasts'), findsOneWidget);
    expect(find.text('Find Phone & Torch'), findsOneWidget);

    await tester.tap(find.text('Wellness'));
    await tester.pumpAndSettle();
    expect(find.text('Guided Breathing & HRV'), findsOneWidget);
    expect(find.text('Temperature Balance'), findsOneWidget);
    expect(find.text('Light & Recovery Insights'), findsOneWidget);

    await tester.tap(find.text('Ring'));
    await tester.pumpAndSettle();
    expect(find.text('Health Sync'), findsOneWidget);
    expect(find.text('Battery Health'), findsOneWidget);
    expect(find.text('On-Ring Tracking'), findsOneWidget);
    expect(find.text('Automatic workout detection'), findsOneWidget);

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
    expect(find.text('Automation'), findsOneWidget);
    expect(find.text('Auto-connect on launch'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Android only'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Health Connect (Android)'), findsOneWidget);
    expect(find.text('Android only'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Android UI exposes Health Connect auto-export on Home and Settings', (
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
