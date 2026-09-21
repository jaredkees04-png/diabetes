import '../../core/utils/date_range.dart';
import '../models/basal_entry.dart';
import '../models/bolus_entry.dart';
import '../models/glucose_entry.dart';
import '../models/range_stats.dart';

class RangeStatsCalculator {
  const RangeStatsCalculator();

  RangeStats calculate({
    required List<BasalEntry> basalEntries,
    required List<BolusEntry> bolusEntries,
    required List<GlucoseEntry> glucoseEntries,
    required DateRange range,
  }) {
    final basal = basalEntries.where((e) => range.contains(e.timestamp)).toList();
    final bolus = bolusEntries.where((e) => range.contains(e.timestamp)).toList();
    final glucose = glucoseEntries.where((e) => range.contains(e.timestamp)).toList();

    final totalBasal = basal.fold<double>(0, (sum, e) => sum + e.units);
    final totalBolus = bolus.fold<double>(0, (sum, e) => sum + e.roundedDose);
    final glucoseAverage = glucose.isEmpty
        ? null
        : glucose.fold<double>(0, (sum, e) => sum + e.reading) / glucose.length;

    return RangeStats(
      totalBasal: totalBasal,
      totalBolus: totalBolus,
      glucoseCount: glucose.length,
      glucoseAverage: glucoseAverage,
      highCount: glucose.where((e) => e.isHigh).length,
      lowCount: glucose.where((e) => e.isLow).length,
    );
  }

  /// One [RangeStats] per calendar day in [range] — lets a week/month view
  /// drill down into per-day patterns instead of just a single total.
  List<MapEntry<DateTime, RangeStats>> calculateDailyBreakdown({
    required List<BasalEntry> basalEntries,
    required List<BolusEntry> bolusEntries,
    required List<GlucoseEntry> glucoseEntries,
    required DateRange range,
  }) {
    final days = <MapEntry<DateTime, RangeStats>>[];
    var day = range.start;
    while (day.isBefore(range.endExclusive)) {
      final dayStats = calculate(
        basalEntries: basalEntries,
        bolusEntries: bolusEntries,
        glucoseEntries: glucoseEntries,
        range: rangeFor(StatsPeriod.day, day),
      );
      days.add(MapEntry(day, dayStats));
      day = day.add(const Duration(days: 1));
    }
    return days;
  }
}
