/// A bolus dose the user confirmed they actually took — distinct from
/// just running the calculator, which doesn't imply a dose was given.
class BolusEntry {
  const BolusEntry({
    required this.id,
    required this.carbsGrams,
    required this.glucoseAtTime,
    required this.carbDose,
    required this.correctionDose,
    required this.roundedDose,
    required this.timestamp,
  });

  final String id;
  final double carbsGrams;
  final double glucoseAtTime;
  final double carbDose;
  final double correctionDose;
  final double roundedDose;
  final DateTime timestamp;

  factory BolusEntry.fromMap(Map<String, Object?> map) {
    return BolusEntry(
      id: map['id'] as String,
      carbsGrams: map['carbs_grams'] as double,
      glucoseAtTime: map['glucose_at_time'] as double,
      carbDose: map['carb_dose'] as double,
      correctionDose: map['correction_dose'] as double,
      roundedDose: map['rounded_dose'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'carbs_grams': carbsGrams,
      'glucose_at_time': glucoseAtTime,
      'carb_dose': carbDose,
      'correction_dose': correctionDose,
      'rounded_dose': roundedDose,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }
}
