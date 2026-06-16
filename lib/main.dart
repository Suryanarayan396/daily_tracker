import 'package:flutter/material.dart';
import 'core/services/sqlite_service.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SqliteService.init();
  runApp(const LifeOSApp());
}

class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0D0E11),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2563EB),
        onPrimary: Colors.white,
        secondary: Color(0xFF10B981),
        onSecondary: Colors.white,
        tertiary: Color(0xFFF59E0B),
        error: Color(0xFFEF4444),
        surface: Color(0xFF1E2026),
        onSurface: Colors.white,
        onSurfaceVariant: Color(0xFF94A3B8),
        outlineVariant: Color(0xFF334155),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );

    return MaterialApp.router(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,
      theme: darkTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
