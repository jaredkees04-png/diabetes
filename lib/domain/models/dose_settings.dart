/// The rounding increments a prescribed dose can be constrained to.
const List<double> kRoundingIncrements = [0.1, 0.5, 1.0];

/// The doctor-prescribed values the bolus calculator does arithmetic on.
/// Stored locally on-device only.
class DoseSettings {
  const DoseSettings({
    required this.carbRatio,
    required this.correctionFactor,
    required this.targetGlucose,
    required this.roundingIncrement,
  });

  /// Grams of carbohydrate covered by one unit of insulin.
  final double carbRatio;

  /// mg/dL that one unit of insulin is expected to lower glucose by.
  final double correctionFactor;

  /// Target blood glucose in mg/dL.
  final double targetGlucose;

  /// Smallest dose step the calculator rounds to (0.1, 0.5, or 1 unit).
  final double roundingIncrement;

  static const defaults = DoseSettings(
    carbRatio: 10,
    correctionFactor: 50,
    targetGlucose: 120,
    roundingIncrement: 0.5,
  );

  DoseSettings copyWith({
    double? carbRatio,
    double? correctionFactor,
    double? targetGlucose,
    double? roundingIncrement,
  }) {
    return DoseSettings(
      carbRatio: carbRatio ?? this.carbRatio,
      correctionFactor: correctionFactor ?? this.correctionFactor,
      targetGlucose: targetGlucose ?? this.targetGlucose,
      roundingIncrement: roundingIncrement ?? this.roundingIncrement,
    );
  }
}
