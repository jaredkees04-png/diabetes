import '../models/label_reading.dart';

/// Pulls a best-guess carbs/sugars-per-serving and serving size out of raw
/// OCR text from a nutrition facts label. Deliberately lenient — the UI
/// always shows these as editable, pre-filled fields rather than trusting
/// them outright.
class NutritionLabelParser {
  const NutritionLabelParser();

  static final _totalCarbs = RegExp(
    r'total\s*carb\w*\D{0,12}(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );
  static final _carbs = RegExp(r'carb\w*\D{0,12}(\d+(?:\.\d+)?)', caseSensitive: false);
  static final _totalSugars = RegExp(
    r'total\s*sugars?\D{0,12}(\d+(?:\.\d+)?)',
    caseSensitive: false,
  );
  static final _sugars = RegExp(r'sugars?\D{0,12}(\d+(?:\.\d+)?)', caseSensitive: false);
  static final _addedSugars = RegExp(r'added\s*sugars?', caseSensitive: false);
  static final _servingSize = RegExp(r'serving\s*size\D*(.+)', caseSensitive: false);

  LabelReading parse(String rawText) {
    final lines = rawText.split(RegExp(r'[\r\n]+')).map((l) => l.trim()).where((l) => l.isNotEmpty);

    final carbs = _firstMatch(_totalCarbs, rawText) ?? _firstMatch(_carbs, rawText);

    double? sugars;
    final sugarLines = lines.where((l) => !_addedSugars.hasMatch(l));
    for (final line in sugarLines) {
      sugars = _firstMatch(_totalSugars, line) ?? _firstMatch(_sugars, line);
      if (sugars != null) break;
    }

    String? servingSize;
    for (final line in lines) {
      final match = _servingSize.firstMatch(line);
      if (match != null) {
        servingSize = match.group(1)?.trim();
        break;
      }
    }

    return LabelReading(carbsPerServing: carbs, sugarsPerServing: sugars, servingSizeText: servingSize);
  }

  double? _firstMatch(RegExp pattern, String text) {
    final match = pattern.firstMatch(text);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }
}
