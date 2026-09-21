import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dose_glucose_log/app/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows a disclaimer dialog on launch that must be dismissed', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoseGlucoseApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('not medical advice'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.textContaining('not medical advice'), findsNothing);
  });

  testWidgets('shows the app bar and all five tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoseGlucoseApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.text('Dose & Glucose Log'), findsWidgets);
    expect(find.text('Bolus'), findsWidgets);
    expect(find.text('Basal'), findsWidgets);
    expect(find.text('Glucose'), findsWidgets);
    expect(find.text('Labels'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('switching tabs does not throw', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoseGlucoseApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    for (final label in ['Basal', 'Glucose', 'Labels', 'Settings', 'Bolus']) {
      await tester.tap(find.text(label).last);
      await tester.pump();
    }
  });
}
