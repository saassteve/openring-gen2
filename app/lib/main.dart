import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'ble/ring_controller.dart';
import 'data/ring_database.dart';
import 'ui/companion_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RingPilotApp());
}

class RingPilotApp extends StatelessWidget {
  const RingPilotApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xffb9ee8e),
      primary: const Color(0xffb9ee8e),
      secondary: const Color(0xff7dd6c8),
      surface: const Color(0xff141c1a),
      brightness: Brightness.dark,
    );
    return ChangeNotifierProvider(
      create: (_) => RingController(RingDatabase()),
      child: MaterialApp(
        title: 'RingPilot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colors,
          scaffoldBackgroundColor: const Color(0xff0c1110),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xff0c1110),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: Color(0xffeaf2ee),
            ),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xff151e1c),
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xff23302c)),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xff111816),
            indicatorColor: const Color(0xffb9ee8e).withValues(alpha: 0.18),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
          chipTheme: ChipThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Color(0xff273530)),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
            titleLarge: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        home: const CompanionScreen(),
      ),
    );
  }
}
