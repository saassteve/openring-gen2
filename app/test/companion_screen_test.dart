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

  testWidgets('Home, Control, Wellness, Ring and Settings fit a narrow phone', (
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
    expect(controller.autoSyncHistory, isTrue);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: const MaterialApp(home: CompanionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RingPilot'), findsOneWidget);
    expect(find.byTooltip('Diagnostics'), findsNothing);
    expect(find.text('Smart Ring'), findsOneWidget);
    expect(find.text('Not connected'), findsOneWidget);
    expect(find.text('Ring Remote'), findsOneWidget);
    expect(find.text("Today's Recovery & Sync"), findsOneWidget);
    expect(find.textContaining('RingConn'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Quick Heart Rate Check'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Quick Heart Rate Check'), findsOneWidget);

    await tester.tap(find.text('Control'));
    await tester.pumpAndSettle();
    expect(find.text('Ring Remote'), findsOneWidget);
    expect(find.text('Music & Podcasts'), findsOneWidget);
    expect(find.text('Find Phone & Torch'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Everyday Automations'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Everyday Automations'), findsOneWidget);

    await tester.tap(find.text('Wellness'));
    await tester.pumpAndSettle();
    expect(find.text('Stress Reset'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sleep Environment & HRV'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Relaxation Check'), findsOneWidget);
    expect(find.text('Sleep Environment & HRV'), findsOneWidget);

    await tester.tap(find.text('Ring'));
    await tester.pumpAndSettle();
    expect(find.text('Automatic Health Sync'), findsOneWidget);
    expect(find.text('Auto-sync HRV, sleep & health data'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Automatic workout detection'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Battery & Lifespan'), findsOneWidget);
    expect(find.text('On-Ring Battery Savers'), findsOneWidget);
    expect(find.text('Automatic workout detection'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Automation'), findsOneWidget);
    expect(find.text('Auto-connect on launch'), findsOneWidget);
    expect(find.text('Auto-sync HRV & health data'), findsOneWidget);
    final settingsScrollable = find
        .descendant(
          of: find.byType(ListView).last,
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      find.text('Reset stuck sensors'),
      200,
      scrollable: settingsScrollable,
    );
    expect(find.text('Health Connect (Android)'), findsOneWidget);
    expect(find.text('Android only'), findsOneWidget);
    expect(find.text('Ring Info & Troubleshooting'), findsOneWidget);
    expect(find.text('Reset stuck sensors'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Developer & Smart Home Tools'),
      200,
      scrollable: settingsScrollable,
    );
    await tester.ensureVisible(find.text('Developer & Smart Home Tools'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Developer & Smart Home Tools'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('BLE Command Console'),
      200,
      scrollable: settingsScrollable,
    );
    await tester.ensureVisible(find.text('BLE Command Console'));
    await tester.pumpAndSettle();
    expect(find.text('Broadcast live events (Tasker / KWGT)'), findsOneWidget);
    expect(find.text('Export debug log'), findsOneWidget);

    await tester.tap(find.text('BLE Command Console'));
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
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Android UI exposes Health Connect auto-export on Home and Settings',
    (tester) async {
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
      await tester.pumpAndSettle();

      expect(
        find.text('Auto-export to Android Health Connect is on.'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Sync to Health Connect now'),
        200,
        scrollable: find.descendant(
          of: find.byType(ListView).last,
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('Health Connect (Android)'), findsOneWidget);
      expect(find.text('Auto-export after sync'), findsOneWidget);
      expect(find.text('Sync to Health Connect now'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
