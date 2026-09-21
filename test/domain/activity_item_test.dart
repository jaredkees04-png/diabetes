import 'package:flutter_test/flutter_test.dart';

import 'package:dose_glucose_log/domain/models/activity_item.dart';
import 'package:dose_glucose_log/domain/models/basal_entry.dart';
import 'package:dose_glucose_log/domain/models/bolus_entry.dart';
import 'package:dose_glucose_log/domain/models/glucose_entry.dart';

void main() {
  test('merges all three entry types and sorts newest-first', () {
    final items = ActivityItem.merge(
      basalEntries: [BasalEntry(id: 'b1', units: 4, timestamp: DateTime(2026, 9, 21, 9))],
      bolusEntries: [
        BolusEntry(
          id: 'x1',
          carbsGrams: 30,
          glucoseAtTime: 150,
          carbDose: 3,
          correctionDose: 0.6,
          roundedDose: 3.5,
          timestamp: DateTime(2026, 9, 21, 12),
        ),
      ],
      glucoseEntries: [
        GlucoseEntry(id: 'g1', reading: 190, timestamp: DateTime(2026, 9, 21, 15)),
      ],
    );

    expect(items.map((i) => i.kind).toList(), [
      ActivityKind.glucose,
      ActivityKind.bolus,
      ActivityKind.basal,
    ]);
    expect(items[0].title, '190 mg/dL');
    expect(items[0].flagged, isTrue); // 190 >= 180
    expect(items[1].title, '3.50 units bolus');
    expect(items[2].title, '4.00 units basal');
  });

  test('returns an empty list when there is nothing to merge', () {
    final items = ActivityItem.merge(basalEntries: [], bolusEntries: [], glucoseEntries: []);
    expect(items, isEmpty);
  });
}
