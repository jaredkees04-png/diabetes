class BasalEntry {
  const BasalEntry({required this.id, required this.units, required this.timestamp});

  final String id;
  final double units;
  final DateTime timestamp;

  factory BasalEntry.fromMap(Map<String, Object?> map) {
    return BasalEntry(
      id: map['id'] as String,
      units: map['units'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'units': units,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
