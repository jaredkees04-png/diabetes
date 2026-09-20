import 'package:flutter/material.dart';

import 'home_shell.dart';

class DoseGlucoseApp extends StatelessWidget {
  const DoseGlucoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dose & Glucose Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00695C),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00695C),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeShell(),
    );
  }
}
