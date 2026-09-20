import 'package:flutter/material.dart';

import '../core/constants/theme_colors.dart';
import 'home_shell.dart';

class DoseGlucoseApp extends StatelessWidget {
  const DoseGlucoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dose & Glucose Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kSeedColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSeedColor,
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kSeedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSeedColor,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeShell(),
    );
  }
}
