import '../../core/constants/glucose_thresholds.dart';

class GlucoseEntry {
  const GlucoseEntry({
    required this.id,
    required this.reading,
    required this.timestamp,
    this.note,
  });

  final String id;
  final double reading;
  final DateTime timestamp;
  final String? note;

  bool get isLow => reading <= kGlucoseLowThreshold;
  bool get isHigh => reading >= kGlucoseHighThreshold;

  factory GlucoseEntry.fromMap(Map<String, Object?> map) {
    return GlucoseEntry(
      id: map['id'] as String,
      reading: map['reading'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      note: map['note'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'reading': reading,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'note': note,
    };
  }
}
