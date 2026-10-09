import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const SonaTasksApp());

class SonaTasksApp extends StatelessWidget {
  const SonaTasksApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SonaTasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF315ACB)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF7F8FC),
        ),
        cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
      ),
      home: const HomeScreen(),
    );
  }
}
