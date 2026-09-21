import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dose_glucose_log/app/app.dart';
import 'package:dose_glucose_log/app/providers.dart';
import 'package:dose_glucose_log/data/database/app_database.dart';
import 'package:dose_glucose_log/data/repositories/basal_repository.dart';
import 'package:dose_glucose_log/data/repositories/glucose_repository.dart';
import 'package:dose_glucose_log/domain/models/basal_entry.dart';
import 'package:dose_glucose_log/domain/models/glucose_entry.dart';

/// Plain sqflite has no platform channel in the widget-test VM, so the
/// real repositories would error out. These stand in with deterministic
/// data instead, so the real notifiers/providers above them run
/// unmodified — only the leaf dependency is faked.
class _FakeBasalRepository extends BasalRepository {
  _FakeBasalRepository(this._entries) : super(AppDatabase());
  final List<BasalEntry> _entries;

  @override
  Future<List<BasalEntry>> getAll() async => _entries;

  @override
  Future<void> insert(BasalEntry entry) async {}

  @override
  Future<void> delete(String id) async {}
}

class _FakeGlucoseRepository extends GlucoseRepository {
  _FakeGlucoseRepository(this._entries) : super(AppDatabase());
  final List<GlucoseEntry> _entries;

  @override
  Future<List<GlucoseEntry>> getAll() async => _entries;

  @override
  Future<void> insert(GlucoseEntry entry) async {}

  @override
  Future<void> delete(String id) async {}
}

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

  testWidgets('shows the app bar and all six tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoseGlucoseApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.text('Dose & Glucose Log'), findsWidgets);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Bolus'), findsWidgets);
    expect(find.text('Basal'), findsWidgets);
    expect(find.text('Glucose'), findsWidgets);
    expect(find.text('Labels'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Home tab shows empty state with no data logged', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          basalRepositoryProvider.overrideWithValue(_FakeBasalRepository(const [])),
          glucoseRepositoryProvider.overrideWithValue(_FakeGlucoseRepository(const [])),
        ],
        child: const DoseGlucoseApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.text('No glucose readings logged yet.'), findsOneWidget);
    expect(find.text('Nothing logged yet.'), findsOneWidget);
  });

  testWidgets('Home tab shows real stats and recent activity when data exists', (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          basalRepositoryProvider.overrideWithValue(
            _FakeBasalRepository([BasalEntry(id: 'b1', units: 4.5, timestamp: now)]),
          ),
          glucoseRepositoryProvider.overrideWithValue(
            _FakeGlucoseRepository([GlucoseEntry(id: 'g1', reading: 190, timestamp: now)]),
          ),
        ],
        child: const DoseGlucoseApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.text('190 mg/dL'), findsWidgets);
    expect(find.text('High'), findsOneWidget); // 190 >= 180 flags high
    expect(find.text('4.5 u'), findsOneWidget); // today's basal total
    expect(find.text('4.50 units basal'), findsOneWidget); // recent activity row
  });

  testWidgets('switching tabs does not throw', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoseGlucoseApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    for (final label in ['Bolus', 'Basal', 'Glucose', 'Labels', 'Settings', 'Home']) {
      await tester.tap(find.text(label).last);
      await tester.pump();
    }
  });
}
