/// The full breakdown of a bolus dose calculation, so the UI can show its
/// work rather than just a final number.
class BolusCalculation {
  const BolusCalculation({
    required this.carbDose,
    required this.correctionDose,
    required this.rawTotal,
    required this.roundedDose,
    required this.isBelowTarget,
    required this.suggestsNoBolus,
  });

  /// carbs ÷ carb ratio, unrounded.
  final double carbDose;

  /// (glucose − target) ÷ correction factor, unrounded. Negative when
  /// glucose is below target.
  final double correctionDose;

  /// carbDose + correctionDose, before clamping or rounding.
  final double rawTotal;

  /// The final dose: rawTotal clamped to zero and rounded to the
  /// configured increment.
  final double roundedDose;

  /// Whether current glucose is below the target — the correction
  /// component is pulling the dose down.
  final bool isBelowTarget;

  /// Whether the rounded dose comes out to zero (or the raw total was
  /// negative), meaning no bolus is indicated by these numbers.
  final bool suggestsNoBolus;
}
