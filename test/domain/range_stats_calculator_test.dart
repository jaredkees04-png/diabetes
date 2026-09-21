import 'package:flutter_test/flutter_test.dart';

import 'package:dose_glucose_log/core/utils/date_range.dart';
import 'package:dose_glucose_log/domain/models/basal_entry.dart';
import 'package:dose_glucose_log/domain/models/bolus_entry.dart';
import 'package:dose_glucose_log/domain/models/glucose_entry.dart';
import 'package:dose_glucose_log/domain/services/range_stats_calculator.dart';

BolusEntry _bolus(String id, double dose, DateTime timestamp) {
  return BolusEntry(
    id: id,
    carbsGrams: 0,
    glucoseAtTime: 0,
    carbDose: 0,
    correctionDose: 0,
    roundedDose: dose,
    timestamp: timestamp,
  );
}

void main() {
  const calculator = RangeStatsCalculator();

  test('sums only entries within the range, week example', () {
    final range = rangeFor(StatsPeriod.week, DateTime(2026, 9, 24)); // Sep 21-27

    final basalEntries = [
      BasalEntry(id: 'b1', units: 5, timestamp: DateTime(2026, 9, 21, 9)), // in range
      BasalEntry(id: 'b2', units: 3, timestamp: DateTime(2026, 9, 27, 23)), // in range
      BasalEntry(id: 'b3', units: 10, timestamp: DateTime(2026, 9, 28, 0)), // just outside
      BasalEntry(id: 'b4', units: 7, timestamp: DateTime(2026, 9, 20, 23)), // just before
    ];
    final bolusEntries = [_bolus('x1', 4, DateTime(2026, 9, 23))];
    final glucoseEntries = [
      GlucoseEntry(id: 'g1', reading: 200, timestamp: DateTime(2026, 9, 22)), // high
      GlucoseEntry(id: 'g2', reading: 60, timestamp: DateTime(2026, 9, 25)), // low
      GlucoseEntry(id: 'g3', reading: 100, timestamp: DateTime(2026, 9, 19)), // outside
    ];

    final stats = calculator.calculate(
      basalEntries: basalEntries,
      bolusEntries: bolusEntries,
      glucoseEntries: glucoseEntries,
      range: range,
    );

    expect(stats.totalBasal, 8); // 5 + 3
    expect(stats.totalBolus, 4);
    expect(stats.glucoseCount, 2);
    expect(stats.glucoseAverage, closeTo(130, 1e-9));
    expect(stats.highCount, 1);
    expect(stats.lowCount, 1);
  });

  test('daily breakdown produces one entry per day with correct per-day totals', () {
    final range = rangeFor(StatsPeriod.day, DateTime(2026, 9, 21)); // single day, sanity check
    final weekRange = rangeFor(StatsPeriod.week, DateTime(2026, 9, 24)); // Sep 21-27

    final basalEntries = [
      BasalEntry(id: 'b1', units: 5, timestamp: DateTime(2026, 9, 21, 9)),
      BasalEntry(id: 'b2', units: 3, timestamp: DateTime(2026, 9, 22, 9)),
    ];

    final breakdown = calculator.calculateDailyBreakdown(
      basalEntries: basalEntries,
      bolusEntries: const [],
      glucoseEntries: const [],
      range: weekRange,
    );

    expect(breakdown.length, 7); // Mon-Sun
    expect(breakdown[0].key, DateTime(2026, 9, 21));
    expect(breakdown[0].value.totalBasal, 5);
    expect(breakdown[1].value.totalBasal, 3);
    expect(breakdown[2].value.totalBasal, 0); // Sep 23, nothing logged
    // A single-day range sanity check on the underlying calculate() too.
    expect(calculator.calculate(basalEntries: basalEntries, bolusEntries: const [], glucoseEntries: const [], range: range).totalBasal, 5);
  });

  test('returns zeros and a null average for an empty range', () {
    final range = rangeFor(StatsPeriod.day, DateTime(2026, 9, 21));
    final stats = calculator.calculate(
      basalEntries: const [],
      bolusEntries: const [],
      glucoseEntries: const [],
      range: range,
    );

    expect(stats.totalBasal, 0);
    expect(stats.totalBolus, 0);
    expect(stats.glucoseCount, 0);
    expect(stats.glucoseAverage, isNull);
  });
}
