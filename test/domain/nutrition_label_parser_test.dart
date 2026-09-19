import 'package:flutter_test/flutter_test.dart';

import 'package:dose_glucose_log/domain/services/nutrition_label_parser.dart';

void main() {
  const parser = NutritionLabelParser();

  test('reads total carbohydrate and total sugars over the generic lines', () {
    const text = '''
Nutrition Facts
Serving Size 1 cup (240ml)
Servings Per Container 2
Amount Per Serving
Calories 150
Total Fat 2g
Total Carbohydrate 30g
Dietary Fiber 3g
Total Sugars 12g
Includes 5g Added Sugars
Protein 5g
''';

    final reading = parser.parse(text);

    expect(reading.carbsPerServing, 30);
    expect(reading.sugarsPerServing, 12);
    expect(reading.servingSizeText, '1 cup (240ml)');
  });

  test('falls back to a plain Carbohydrate/Sugars line when "Total" is missing', () {
    const text = '''
Carbohydrate 18 g
Sugars 6 g
''';

    final reading = parser.parse(text);

    expect(reading.carbsPerServing, 18);
    expect(reading.sugarsPerServing, 6);
  });

  test('skips an Added Sugars line when picking the sugars value', () {
    const text = '''
Total Carbohydrate 22g
Added Sugars 9g
Sugars 14g
''';

    final reading = parser.parse(text);

    // The Added Sugars line is skipped entirely, so the plain Sugars line wins.
    expect(reading.sugarsPerServing, 14);
  });

  test('returns nulls when nothing recognizable is present', () {
    final reading = parser.parse('this is not a nutrition label at all');

    expect(reading.carbsPerServing, isNull);
    expect(reading.sugarsPerServing, isNull);
    expect(reading.servingSizeText, isNull);
  });
}
