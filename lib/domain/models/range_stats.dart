/// Aggregated totals over an arbitrary date range (a day, week, or month),
/// computed on the fly from the basal/bolus/glucose logs.
class RangeStats {
  const RangeStats({
    required this.totalBasal,
    required this.totalBolus,
    required this.glucoseCount,
    required this.glucoseAverage,
    required this.highCount,
    required this.lowCount,
  });

  final double totalBasal;
  final double totalBolus;
  final int glucoseCount;
  final double? glucoseAverage;
  final int highCount;
  final int lowCount;
}
