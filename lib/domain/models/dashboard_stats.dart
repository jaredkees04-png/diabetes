import '../models/basal_entry.dart';
import '../models/glucose_entry.dart';

/// A quick-glance summary of today's activity, computed from the basal,
/// bolus, and glucose logs — nothing here is stored, it's derived on demand.
class DashboardStats {
  const DashboardStats({
    required this.latestGlucose,
    required this.latestBasal,
    required this.todayBasalTotal,
    required this.todayBolusTotal,
    required this.todayGlucoseCount,
    required this.todayGlucoseAverage,
    required this.todayHighCount,
    required this.todayLowCount,
  });

  final GlucoseEntry? latestGlucose;
  final BasalEntry? latestBasal;
  final double todayBasalTotal;
  final double todayBolusTotal;
  final int todayGlucoseCount;
  final double? todayGlucoseAverage;
  final int todayHighCount;
  final int todayLowCount;
}
