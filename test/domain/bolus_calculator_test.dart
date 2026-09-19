import 'package:flutter_test/flutter_test.dart';

import 'package:dose_glucose_log/domain/models/dose_settings.dart';
import 'package:dose_glucose_log/domain/services/bolus_calculator.dart';

void main() {
  const calculator = BolusCalculator();
  const settings = DoseSettings(
    carbRatio: 10,
    correctionFactor: 50,
    targetGlucose: 120,
    roundingIncrement: 0.5,
  );

  test('computes carb and correction components and sums them', () {
    final result = calculator.calculate(
      carbsGrams: 45,
      currentGlucose: 220,
      settings: settings,
    );

    expect(result.carbDose, closeTo(4.5, 1e-9));
    expect(result.correctionDose, closeTo(2.0, 1e-9));
    expect(result.rawTotal, closeTo(6.5, 1e-9));
    expect(result.roundedDose, 6.5);
    expect(result.isBelowTarget, isFalse);
    expect(result.suggestsNoBolus, isFalse);
  });

  test('rounds to the configured increment', () {
    final quarterUnit = calculator.calculate(
      carbsGrams: 40,
      currentGlucose: 120,
      settings: settings, // 40/10 = 4.0 exactly, no rounding needed
    );
    expect(quarterUnit.roundedDose, 4.0);

    final needsRounding = calculator.calculate(
      carbsGrams: 43,
      currentGlucose: 120,
      settings: settings, // 4.3 -> nearest 0.5 -> 4.5
    );
    expect(needsRounding.roundedDose, 4.5);

    final wholeUnitSettings = settings.copyWith(roundingIncrement: 1.0);
    final wholeUnit = calculator.calculate(
      carbsGrams: 43,
      currentGlucose: 120,
      settings: wholeUnitSettings, // 4.3 -> nearest 1 -> 4.0
    );
    expect(wholeUnit.roundedDose, 4.0);

    final tenthSettings = settings.copyWith(roundingIncrement: 0.1);
    final tenth = calculator.calculate(
      carbsGrams: 43,
      currentGlucose: 120,
      settings: tenthSettings, // 4.3 exactly
    );
    expect(tenth.roundedDose, 4.3);
  });

  test('flags glucose below target and warns when no bolus is needed', () {
    final result = calculator.calculate(
      carbsGrams: 0,
      currentGlucose: 90,
      settings: settings, // (90-120)/50 = -0.6, no carbs to offset it
    );

    expect(result.isBelowTarget, isTrue);
    expect(result.rawTotal, lessThan(0));
    expect(result.roundedDose, 0);
    expect(result.suggestsNoBolus, isTrue);
  });

  test('never recommends a negative dose', () {
    final result = calculator.calculate(
      carbsGrams: 5,
      currentGlucose: 60,
      settings: settings,
    );

    expect(result.roundedDose, greaterThanOrEqualTo(0));
  });
}
