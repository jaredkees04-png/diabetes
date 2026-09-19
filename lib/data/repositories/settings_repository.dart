import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/dose_settings.dart';

/// Persists the prescribed dosing settings with [SharedPreferences] —
/// a handful of scalars, kept locally on-device only.
class SettingsRepository {
  static const _carbRatioKey = 'dose_settings.carb_ratio';
  static const _correctionFactorKey = 'dose_settings.correction_factor';
  static const _targetGlucoseKey = 'dose_settings.target_glucose';
  static const _roundingIncrementKey = 'dose_settings.rounding_increment';

  Future<DoseSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final defaults = DoseSettings.defaults;
    return DoseSettings(
      carbRatio: prefs.getDouble(_carbRatioKey) ?? defaults.carbRatio,
      correctionFactor: prefs.getDouble(_correctionFactorKey) ?? defaults.correctionFactor,
      targetGlucose: prefs.getDouble(_targetGlucoseKey) ?? defaults.targetGlucose,
      roundingIncrement: prefs.getDouble(_roundingIncrementKey) ?? defaults.roundingIncrement,
    );
  }

  Future<void> save(DoseSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_carbRatioKey, settings.carbRatio);
    await prefs.setDouble(_correctionFactorKey, settings.correctionFactor);
    await prefs.setDouble(_targetGlucoseKey, settings.targetGlucose);
    await prefs.setDouble(_roundingIncrementKey, settings.roundingIncrement);
  }
}
