import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/utils/relative_time.dart';
import '../../domain/models/activity_item.dart';
import '../../domain/models/basal_entry.dart';
import '../../domain/models/bolus_entry.dart';
import '../../domain/models/dashboard_stats.dart';
import '../../domain/models/glucose_entry.dart';
import '../../domain/services/dashboard_stats_calculator.dart';
import '../../widgets/activity_tile.dart';
import '../../widgets/stat_tile.dart';

const _calculator = DashboardStatsCalculator();

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final basalAsync = ref.watch(basalEntriesProvider);
    final bolusAsync = ref.watch(bolusEntriesProvider);
    final glucoseAsync = ref.watch(glucoseEntriesProvider);

    if (basalAsync.isLoading || bolusAsync.isLoading || glucoseAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = basalAsync.error ?? bolusAsync.error ?? glucoseAsync.error;
    if (error != null) {
      return Center(child: Text('Could not load your data: $error'));
    }

    final basalEntries = basalAsync.value ?? const <BasalEntry>[];
    final bolusEntries = bolusAsync.value ?? const <BolusEntry>[];
    final glucoseEntries = glucoseAsync.value ?? const <GlucoseEntry>[];
    final stats = _calculator.calculate(
      basalEntries: basalEntries,
      bolusEntries: bolusEntries,
      glucoseEntries: glucoseEntries,
      now: DateTime.now(),
    );

    final activity = ActivityItem.merge(
      basalEntries: basalEntries,
      bolusEntries: bolusEntries,
      glucoseEntries: glucoseEntries,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LatestGlucoseCard(latest: stats.latestGlucose),
          const SizedBox(height: 16),
          _StatsGrid(stats: stats),
          const SizedBox(height: 20),
          Text('Recent activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (activity.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Nothing logged yet.')),
            )
          else
            ...activity.take(8).map((item) => ActivityTile(item: item)),
        ],
      ),
    );
  }
}

class _LatestGlucoseCard extends StatelessWidget {
  const _LatestGlucoseCard({required this.latest});

  final GlucoseEntry? latest;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (latest == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.bloodtype_outlined, color: colorScheme.primary, size: 32),
              const SizedBox(height: 8),
              const Text('No glucose readings logged yet.'),
            ],
          ),
        ),
      );
    }

    final entry = latest!;
    final flagged = entry.isHigh || entry.isLow;
    final valueColor = flagged ? colorScheme.error : colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Latest glucose', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              '${entry.reading.toStringAsFixed(0)} mg/dL',
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: valueColor),
            ),
            const SizedBox(height: 4),
            Text(relativeTime(entry.timestamp), style: theme.textTheme.bodySmall),
            if (entry.isHigh) _FlagChip(label: 'High', color: colorScheme.error),
            if (entry.isLow) _FlagChip(label: 'Low', color: colorScheme.error),
          ],
        ),
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  const _FlagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      StatTile(label: "Today's basal", value: '${stats.todayBasalTotal.toStringAsFixed(1)} u'),
      StatTile(label: "Today's bolus", value: '${stats.todayBolusTotal.toStringAsFixed(1)} u'),
      StatTile(label: 'Readings today', value: '${stats.todayGlucoseCount}'),
      StatTile(
        label: 'Avg glucose today',
        value: stats.todayGlucoseAverage == null
            ? '–'
            : '${stats.todayGlucoseAverage!.toStringAsFixed(0)} mg/dL',
      ),
      StatTile(
        label: 'High / low today',
        value: '${stats.todayHighCount} / ${stats.todayLowCount}',
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: tiles,
    );
  }
}

