import '../models/bolus_calculation.dart';
import '../models/dose_settings.dart';

/// Pure arithmetic on doctor-prescribed settings. This is a calculator,
/// not a clinical decision system — it has no knowledge of insulin on
/// board, activity, illness, or anything else a care team would weigh.
class BolusCalculator {
  const BolusCalculator();

  BolusCalculation calculate({
    required double carbsGrams,
    required double currentGlucose,
    required DoseSettings settings,
  }) {
    final carbDose = settings.carbRatio > 0 ? carbsGrams / settings.carbRatio : 0.0;
    final correctionDose = settings.correctionFactor > 0
        ? (currentGlucose - settings.targetGlucose) / settings.correctionFactor
        : 0.0;
    final rawTotal = carbDose + correctionDose;
    final clamped = rawTotal < 0 ? 0.0 : rawTotal;
    final roundedDose = _roundToIncrement(clamped, settings.roundingIncrement);

    return BolusCalculation(
      carbDose: carbDose,
      correctionDose: correctionDose,
      rawTotal: rawTotal,
      roundedDose: roundedDose,
      isBelowTarget: currentGlucose < settings.targetGlucose,
      suggestsNoBolus: roundedDose <= 0,
    );
  }

  double _roundToIncrement(double value, double increment) {
    if (increment <= 0) return value;
    final steps = (value / increment).round();
    final rounded = steps * increment;
    // Clean up binary-float artifacts (e.g. 0.30000000000000004).
    return double.parse(rounded.toStringAsFixed(2));
  }
}
