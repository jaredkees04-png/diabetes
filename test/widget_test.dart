import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dose_glucose_log/app/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the app bar, disclaimer, and all five tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoseGlucoseApp()));
    await tester.pump();

    expect(find.text('Dose & Glucose Log'), findsWidgets);
    expect(find.textContaining('not medical advice'), findsOneWidget);
    expect(find.text('Bolus'), findsWidgets);
    expect(find.text('Basal'), findsWidgets);
    expect(find.text('Glucose'), findsWidgets);
    expect(find.text('Labels'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('switching tabs does not throw', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoseGlucoseApp()));
    await tester.pump();

    for (final label in ['Basal', 'Glucose', 'Labels', 'Settings', 'Bolus']) {
      await tester.tap(find.text(label).last);
      await tester.pump();
    }
  });
}
