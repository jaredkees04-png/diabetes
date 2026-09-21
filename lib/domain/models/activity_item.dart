import 'basal_entry.dart';
import 'bolus_entry.dart';
import 'glucose_entry.dart';

enum ActivityKind { basal, bolus, glucose }

/// A single basal/bolus/glucose entry, normalized for display in a merged,
/// chronological log — used by both the Home dashboard and History screen.
class ActivityItem {
  const ActivityItem({
    required this.kind,
    required this.timestamp,
    required this.title,
    this.flagged = false,
  });

  final ActivityKind kind;
  final DateTime timestamp;
  final String title;
  final bool flagged;

  factory ActivityItem.fromBasal(BasalEntry entry) {
    return ActivityItem(
      kind: ActivityKind.basal,
      timestamp: entry.timestamp,
      title: '${entry.units.toStringAsFixed(2)} units basal',
    );
  }

  factory ActivityItem.fromBolus(BolusEntry entry) {
    return ActivityItem(
      kind: ActivityKind.bolus,
      timestamp: entry.timestamp,
      title: '${entry.roundedDose.toStringAsFixed(2)} units bolus',
    );
  }

  factory ActivityItem.fromGlucose(GlucoseEntry entry) {
    return ActivityItem(
      kind: ActivityKind.glucose,
      timestamp: entry.timestamp,
      title: '${entry.reading.toStringAsFixed(0)} mg/dL',
      flagged: entry.isHigh || entry.isLow,
    );
  }

  /// Merges and sorts newest-first — the common case for every screen that
  /// shows a combined log.
  static List<ActivityItem> merge({
    required List<BasalEntry> basalEntries,
    required List<BolusEntry> bolusEntries,
    required List<GlucoseEntry> glucoseEntries,
  }) {
    final items = <ActivityItem>[
      ...basalEntries.map(ActivityItem.fromBasal),
      ...bolusEntries.map(ActivityItem.fromBolus),
      ...glucoseEntries.map(ActivityItem.fromGlucose),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }
}
