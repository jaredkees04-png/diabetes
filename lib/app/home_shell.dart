import 'package:flutter/material.dart';

import '../features/basal/basal_screen.dart';
import '../features/bolus/bolus_screen.dart';
import '../features/food_label/food_label_list_screen.dart';
import '../features/glucose/glucose_screen.dart';
import '../features/home/home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../widgets/disclaimer_banner.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;

  static const _screens = [
    HomeScreen(),
    BolusScreen(),
    BasalScreen(),
    GlucoseScreen(),
    FoodLabelListScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showDisclaimerDialog(context);
    });
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: const SettingsScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dose & Glucose Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: IndexedStack(index: _tabIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Bolus'),
          NavigationDestination(icon: Icon(Icons.schedule_outlined), label: 'Basal'),
          NavigationDestination(icon: Icon(Icons.bloodtype_outlined), label: 'Glucose'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Labels'),
        ],
      ),
    );
  }
}
