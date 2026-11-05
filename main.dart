import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/task_store.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TaskStore()..load(),
      child: const TaskWiseApp(),
    ),
  );
}

class TaskWiseApp extends StatelessWidget {
  const TaskWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<TaskStore>();

    ThemeMode themeMode = ThemeMode.system;
    if (store.themeModeSetting == 'Light') themeMode = ThemeMode.light;
    if (store.themeModeSetting == 'Dark') themeMode = ThemeMode.dark;

    return MaterialApp(
      title: 'TaskWise',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6), brightness: Brightness.dark),
      ),
      home: store.loading
          ? const SplashScreen()
          : (store.isLoggedIn ? const MainNavigationScreen() : const AuthScreen()),
    );
  }
}