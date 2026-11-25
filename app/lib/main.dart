import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import 'ble/ring_controller.dart';
import 'data/ring_database.dart';
import 'ui/companion_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RingCompanionApp());
}

class RingCompanionApp extends StatelessWidget {
  const RingCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xffb8e787),
      primary: const Color(0xffc2ed96),
      secondary: const Color(0xff8ed0c8),
      surface: const Color(0xff151a19),
      brightness: Brightness.dark,
    );
    return ChangeNotifierProvider(
      create: (_) => RingController(RingDatabase()),
      child: MaterialApp(
        title: 'Ring Companion',
        theme: ThemeData(
          colorScheme: colors,
          scaffoldBackgroundColor: const Color(0xff101513),
          useMaterial3: true,
          cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
            titleLarge: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        home: const CompanionScreen(),
      ),
    );
  }
}
