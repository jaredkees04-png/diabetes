import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dose_glucose_log/app/app.dart';
import 'package:dose_glucose_log/app/providers.dart';
import 'package:dose_glucose_log/data/database/app_database.dart';
import 'package:dose_glucose_log/data/repositories/basal_repository.dart';
import 'package:dose_glucose_log/data/repositories/bolus_repository.dart';
import 'package:dose_glucose_log/data/repositories/glucose_repository.dart';
import 'package:dose_glucose_log/domain/models/basal_entry.dart';
import 'package:dose_glucose_log/domain/models/bolus_entry.dart';
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

class _FakeBolusRepository extends BolusRepository {
  _FakeBolusRepository(this._entries) : super(AppDatabase());
  final List<BolusEntry> _entries;

  @override
  Future<List<BolusEntry>> getAll() async => _entries;

  @override
  Future<void> insert(BolusEntry entry) async {}

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

/// Convenience: a ProviderScope with all three log repositories faked, so
/// Home/History render their real (non-error) states.
Widget _appWithData({
  List<BasalEntry> basal = const [],
  List<BolusEntry> bolus = const [],
  List<GlucoseEntry> glucose = const [],
}) {
  return ProviderScope(
    overrides: [
      basalRepositoryProvider.overrideWithValue(_FakeBasalRepository(basal)),
      bolusRepositoryProvider.overrideWithValue(_FakeBolusRepository(bolus)),
      glucoseRepositoryProvider.overrideWithValue(_FakeGlucoseRepository(glucose)),
    ],
    child: const DoseGlucoseApp(),
  );
}

Future<void> _dismissDisclaimer(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.text('Got it'));
  await tester.pumpAndSettle();
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

  testWidgets('shows the app bar and all seven tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoseGlucoseApp()));
    await _dismissDisclaimer(tester);

    expect(find.text('Dose & Glucose Log'), findsWidgets);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('History'), findsWidgets);
    expect(find.text('Bolus'), findsWidgets);
    expect(find.text('Basal'), findsWidgets);
    expect(find.text('Glucose'), findsWidgets);
    expect(find.text('Labels'), findsWidgets);
    expect(find.text('Settings'), findsWidgets);
  });

  testWidgets('Home tab shows empty state with no data logged', (tester) async {
    await tester.pumpWidget(_appWithData());
    await _dismissDisclaimer(tester);

    expect(find.text('No glucose readings logged yet.'), findsOneWidget);
    expect(find.text('Nothing logged yet.'), findsOneWidget);
  });

  testWidgets('Home tab shows real stats and recent activity when data exists', (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      _appWithData(
        basal: [BasalEntry(id: 'b1', units: 4.5, timestamp: now)],
        glucose: [GlucoseEntry(id: 'g1', reading: 190, timestamp: now)],
      ),
    );
    await _dismissDisclaimer(tester);

    expect(find.text('190 mg/dL'), findsWidgets);
    expect(find.text('High'), findsOneWidget); // 190 >= 180 flags high
    expect(find.text('4.5 u'), findsWidgets); // today's basal total
    expect(find.text('4.50 units basal'), findsOneWidget); // recent activity row
  });

  testWidgets('History tab (Day view) shows empty state with no data logged', (tester) async {
    await tester.pumpWidget(_appWithData());
    await _dismissDisclaimer(tester);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    expect(find.text('Nothing logged this day.'), findsOneWidget);
  });

  testWidgets('History tab (Day view) shows entries logged today', (tester) async {
    final now = DateTime.now();
    await tester.pumpWidget(
      _appWithData(
        basal: [BasalEntry(id: 'b1', units: 6, timestamp: now)],
        bolus: [
          BolusEntry(
            id: 'x1',
            carbsGrams: 40,
            glucoseAtTime: 160,
            carbDose: 4,
            correctionDose: 0.8,
            roundedDose: 4.5,
            timestamp: now,
          ),
        ],
        glucose: [GlucoseEntry(id: 'g1', reading: 65, timestamp: now)],
      ),
    );
    await _dismissDisclaimer(tester);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    expect(find.text('6.0 u'), findsOneWidget); // total basal stat tile
    expect(find.text('4.5 u'), findsOneWidget); // total bolus stat tile
    expect(find.text('6.00 units basal'), findsOneWidget);
    expect(find.text('4.50 units bolus'), findsOneWidget);
    expect(find.text('65 mg/dL'), findsWidgets);
  });

  testWidgets('History tab switches to a day-by-day breakdown for Week/Month', (tester) async {
    await tester.pumpWidget(_appWithData());
    await _dismissDisclaimer(tester);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(find.text('Day by day'), findsOneWidget);

    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(find.text('Day by day'), findsOneWidget);
  });

  testWidgets('switching tabs does not throw', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoseGlucoseApp()));
    await _dismissDisclaimer(tester);

    for (final label in ['History', 'Bolus', 'Basal', 'Glucose', 'Labels', 'Settings', 'Home']) {
      await tester.tap(find.text(label).last);
      await tester.pump();
    }
  });
}
