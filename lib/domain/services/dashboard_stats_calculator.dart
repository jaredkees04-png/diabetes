import '../models/basal_entry.dart';
import '../models/bolus_entry.dart';
import '../models/dashboard_stats.dart';
import '../models/glucose_entry.dart';

/// All entry lists are assumed sorted newest-first, matching how the
/// repositories already return them (`ORDER BY timestamp DESC`).
class DashboardStatsCalculator {
  const DashboardStatsCalculator();

  DashboardStats calculate({
    required List<BasalEntry> basalEntries,
    required List<BolusEntry> bolusEntries,
    required List<GlucoseEntry> glucoseEntries,
    required DateTime now,
  }) {
    bool isToday(DateTime t) => t.year == now.year && t.month == now.month && t.day == now.day;

    final todayGlucose = glucoseEntries.where((e) => isToday(e.timestamp)).toList();
    final todayBasal = basalEntries.where((e) => isToday(e.timestamp)).toList();
    final todayBolus = bolusEntries.where((e) => isToday(e.timestamp)).toList();

    final todayBasalTotal = todayBasal.fold<double>(0, (sum, e) => sum + e.units);
    final todayBolusTotal = todayBolus.fold<double>(0, (sum, e) => sum + e.roundedDose);
    final todayGlucoseAverage = todayGlucose.isEmpty
        ? null
        : todayGlucose.fold<double>(0, (sum, e) => sum + e.reading) / todayGlucose.length;

    return DashboardStats(
      latestGlucose: glucoseEntries.isEmpty ? null : glucoseEntries.first,
      latestBasal: basalEntries.isEmpty ? null : basalEntries.first,
      todayBasalTotal: todayBasalTotal,
      todayBolusTotal: todayBolusTotal,
      todayGlucoseCount: todayGlucose.length,
      todayGlucoseAverage: todayGlucoseAverage,
      todayHighCount: todayGlucose.where((e) => e.isHigh).length,
      todayLowCount: todayGlucose.where((e) => e.isLow).length,
    );
  }
}
