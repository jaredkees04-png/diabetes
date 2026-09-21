import 'package:flutter_test/flutter_test.dart';

import 'package:dose_glucose_log/domain/models/basal_entry.dart';
import 'package:dose_glucose_log/domain/models/glucose_entry.dart';
import 'package:dose_glucose_log/domain/services/dashboard_stats_calculator.dart';

void main() {
  const calculator = DashboardStatsCalculator();
  final now = DateTime(2026, 9, 21, 15, 0);
  final earlierToday = DateTime(2026, 9, 21, 8, 0);
  final yesterday = DateTime(2026, 9, 20, 12, 0);

  test('only counts today\'s entries toward today\'s totals', () {
    final basalEntries = [
      BasalEntry(id: 'b1', units: 5, timestamp: now),
      BasalEntry(id: 'b2', units: 3, timestamp: earlierToday),
      BasalEntry(id: 'b3', units: 10, timestamp: yesterday),
    ];
    final glucoseEntries = [
      GlucoseEntry(id: 'g1', reading: 200, timestamp: now), // high
      GlucoseEntry(id: 'g2', reading: 65, timestamp: earlierToday), // low
      GlucoseEntry(id: 'g3', reading: 150, timestamp: yesterday), // not today
    ];

    final stats = calculator.calculate(
      basalEntries: basalEntries,
      glucoseEntries: glucoseEntries,
      now: now,
    );

    expect(stats.todayBasalTotal, 8); // 5 + 3, not the 10 from yesterday
    expect(stats.todayGlucoseCount, 2);
    expect(stats.todayGlucoseAverage, closeTo(132.5, 1e-9)); // (200+65)/2
    expect(stats.todayHighCount, 1);
    expect(stats.todayLowCount, 1);
    expect(stats.latestGlucose?.id, 'g1');
    expect(stats.latestBasal?.id, 'b1');
  });

  test('returns nulls and zeros when there is no data at all', () {
    final stats = calculator.calculate(basalEntries: [], glucoseEntries: [], now: now);

    expect(stats.latestGlucose, isNull);
    expect(stats.latestBasal, isNull);
    expect(stats.todayBasalTotal, 0);
    expect(stats.todayGlucoseCount, 0);
    expect(stats.todayGlucoseAverage, isNull);
    expect(stats.todayHighCount, 0);
    expect(stats.todayLowCount, 0);
  });

  test('latest entries can be from a prior day when nothing logged today', () {
    final basalEntries = [BasalEntry(id: 'b1', units: 4, timestamp: yesterday)];
    final glucoseEntries = [GlucoseEntry(id: 'g1', reading: 110, timestamp: yesterday)];

    final stats = calculator.calculate(
      basalEntries: basalEntries,
      glucoseEntries: glucoseEntries,
      now: now,
    );

    expect(stats.latestBasal?.id, 'b1');
    expect(stats.latestGlucose?.id, 'g1');
    expect(stats.todayBasalTotal, 0);
    expect(stats.todayGlucoseCount, 0);
  });
}
