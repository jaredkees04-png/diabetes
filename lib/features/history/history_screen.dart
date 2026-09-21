import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/providers.dart';
import '../../core/utils/date_range.dart';
import '../../domain/models/activity_item.dart';
import '../../domain/models/basal_entry.dart';
import '../../domain/models/bolus_entry.dart';
import '../../domain/models/glucose_entry.dart';
import '../../domain/models/range_stats.dart';
import '../../domain/services/range_stats_calculator.dart';
import '../../widgets/activity_tile.dart';
import '../../widgets/stat_tile.dart';

const _calculator = RangeStatsCalculator();
final _dayLabelFormat = DateFormat('EEEE, MMM d, y');
final _monthLabelFormat = DateFormat('MMMM y');
final _monthDayFormat = DateFormat('MMM d');
final _dayOnlyFormat = DateFormat('d');
final _weekdayFormat = DateFormat('EEE');

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  StatsPeriod _period = StatsPeriod.day;

  // Null means "not pinned to a specific date" — the History tab tracks
  // the live current date. The tab's State is kept alive for the app's
  // entire lifetime (HomeShell uses IndexedStack), so a plain
  // `DateTime.now()` field would freeze at whatever moment the app
  // launched and go stale across a midnight rollover.
  DateTime? _pinnedAnchor;
  DateTime get _anchor => _pinnedAnchor ?? DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchor,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _pinnedAnchor = picked);
  }

  void _shift(int direction) {
    setState(() => _pinnedAnchor = shiftAnchor(_period, _anchor, direction));
  }

  void _goToToday() {
    setState(() => _pinnedAnchor = null);
  }

  void _openDay(DateTime day) {
    setState(() {
      _period = StatsPeriod.day;
      _pinnedAnchor = day;
    });
  }

  String _rangeLabel(DateRange range) {
    switch (_period) {
      case StatsPeriod.day:
        return _dayLabelFormat.format(range.start);
      case StatsPeriod.month:
        return _monthLabelFormat.format(range.start);
      case StatsPeriod.week:
        final endInclusive = range.endExclusive.subtract(const Duration(days: 1));
        return '${_monthDayFormat.format(range.start)} – ${_monthDayFormat.format(endInclusive)}, ${endInclusive.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final basalAsync = ref.watch(basalEntriesProvider);
    final bolusAsync = ref.watch(bolusEntriesProvider);
    final glucoseAsync = ref.watch(glucoseEntriesProvider);

    if (basalAsync.isLoading || bolusAsync.isLoading || glucoseAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final error = basalAsync.error ?? bolusAsync.error ?? glucoseAsync.error;
    if (error != null) {
      return Center(child: Text('Could not load your data: $error'));
    }

    final basalEntries = basalAsync.value ?? const <BasalEntry>[];
    final bolusEntries = bolusAsync.value ?? const <BolusEntry>[];
    final glucoseEntries = glucoseAsync.value ?? const <GlucoseEntry>[];

    final range = rangeFor(_period, _anchor);
    final stats = _calculator.calculate(
      basalEntries: basalEntries,
      bolusEntries: bolusEntries,
      glucoseEntries: glucoseEntries,
      range: range,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<StatsPeriod>(
            segments: const [
              ButtonSegment(value: StatsPeriod.day, label: Text('Day')),
              ButtonSegment(value: StatsPeriod.week, label: Text('Week')),
              ButtonSegment(value: StatsPeriod.month, label: Text('Month')),
            ],
            selected: {_period},
            onSelectionChanged: (selection) => setState(() => _period = selection.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _shift(-1),
              ),
              Expanded(
                child: TextButton(
                  onPressed: _pickDate,
                  child: Text(_rangeLabel(range), textAlign: TextAlign.center),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _shift(1),
              ),
              IconButton(
                icon: const Icon(Icons.today_outlined),
                tooltip: 'Jump to today',
                onPressed: _goToToday,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatsGrid(stats: stats),
                const SizedBox(height: 20),
                if (_period == StatsPeriod.day)
                  _DayLog(
                    range: range,
                    basalEntries: basalEntries,
                    bolusEntries: bolusEntries,
                    glucoseEntries: glucoseEntries,
                  )
                else
                  _DailyBreakdownList(
                    range: range,
                    basalEntries: basalEntries,
                    bolusEntries: bolusEntries,
                    glucoseEntries: glucoseEntries,
                    onDayTap: _openDay,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final RangeStats stats;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      StatTile(label: 'Total basal', value: '${stats.totalBasal.toStringAsFixed(1)} u'),
      StatTile(label: 'Total bolus', value: '${stats.totalBolus.toStringAsFixed(1)} u'),
      StatTile(label: 'Readings', value: '${stats.glucoseCount}'),
      StatTile(
        label: 'Avg glucose',
        value: stats.glucoseAverage == null
            ? '–'
            : '${stats.glucoseAverage!.toStringAsFixed(0)} mg/dL',
      ),
      StatTile(label: 'High / low', value: '${stats.highCount} / ${stats.lowCount}'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: tiles,
    );
  }
}

class _DayLog extends StatelessWidget {
  const _DayLog({
    required this.range,
    required this.basalEntries,
    required this.bolusEntries,
    required this.glucoseEntries,
  });

  final DateRange range;
  final List<BasalEntry> basalEntries;
  final List<BolusEntry> bolusEntries;
  final List<GlucoseEntry> glucoseEntries;

  @override
  Widget build(BuildContext context) {
    final filteredBasal = basalEntries.where((e) => range.contains(e.timestamp)).toList();
    final filteredBolus = bolusEntries.where((e) => range.contains(e.timestamp)).toList();
    final filteredGlucose = glucoseEntries.where((e) => range.contains(e.timestamp)).toList();
    final items = ActivityItem.merge(
      basalEntries: filteredBasal,
      bolusEntries: filteredBolus,
      glucoseEntries: filteredGlucose,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Log', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('Nothing logged this day.')),
          )
        else
          ...items.map((item) => ActivityTile(item: item)),
      ],
    );
  }
}

class _DailyBreakdownList extends StatelessWidget {
  const _DailyBreakdownList({
    required this.range,
    required this.basalEntries,
    required this.bolusEntries,
    required this.glucoseEntries,
    required this.onDayTap,
  });

  final DateRange range;
  final List<BasalEntry> basalEntries;
  final List<BolusEntry> bolusEntries;
  final List<GlucoseEntry> glucoseEntries;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final breakdown = _calculator.calculateDailyBreakdown(
      basalEntries: basalEntries,
      bolusEntries: bolusEntries,
      glucoseEntries: glucoseEntries,
      range: range,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Day by day', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...breakdown.map((entry) => _DayBreakdownRow(
              day: entry.key,
              stats: entry.value,
              onTap: () => onDayTap(entry.key),
            )),
      ],
    );
  }
}

class _DayBreakdownRow extends StatelessWidget {
  const _DayBreakdownRow({required this.day, required this.stats, required this.onTap});

  final DateTime day;
  final RangeStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasData = stats.glucoseCount > 0 || stats.totalBasal > 0 || stats.totalBolus > 0;
    final colorScheme = Theme.of(context).colorScheme;

    final summary = hasData
        ? '${stats.totalBasal.toStringAsFixed(1)}u basal · '
            '${stats.totalBolus.toStringAsFixed(1)}u bolus · '
            '${stats.glucoseAverage == null ? 'no readings' : 'avg ${stats.glucoseAverage!.toStringAsFixed(0)}'}'
            '${stats.highCount + stats.lowCount > 0 ? ' · ${stats.highCount}H ${stats.lowCount}L' : ''}'
        : 'No data';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: SizedBox(
        width: 40,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_dayOnlyFormat.format(day),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(_weekdayFormat.format(day), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      title: Text(
        summary,
        style: hasData ? null : TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
