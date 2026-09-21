import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../domain/models/basal_entry.dart';

const _uuid = Uuid();
final _timestampFormat = DateFormat('MMM d, y • h:mm a');

class BasalScreen extends ConsumerStatefulWidget {
  const BasalScreen({super.key});

  @override
  ConsumerState<BasalScreen> createState() => _BasalScreenState();
}

class _BasalScreenState extends ConsumerState<BasalScreen> {
  final _unitsController = TextEditingController();

  // Null means "not pinned to a specific time" — defaults to the live
  // current time. This screen's State is kept alive for the app's entire
  // lifetime (HomeShell uses IndexedStack), so a plain `DateTime.now()`
  // field would freeze at whatever moment the app launched and, if never
  // touched, log a stale timestamp on the next entry.
  DateTime? _pinnedTimestamp;
  DateTime get _timestamp => _pinnedTimestamp ?? DateTime.now();

  @override
  void dispose() {
    _unitsController.dispose();
    super.dispose();
  }

  Future<void> _pickTimestamp() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );
    if (time == null) return;
    setState(() {
      _pinnedTimestamp = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addEntry() async {
    final units = double.tryParse(_unitsController.text);
    if (units == null) return;

    await ref.read(basalEntriesProvider.notifier).add(
          BasalEntry(id: _uuid.v4(), units: units, timestamp: _timestamp),
        );
    _unitsController.clear();
    setState(() => _pinnedTimestamp = null);
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(basalEntriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _unitsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Units',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTimestamp,
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        _timestampFormat.format(_timestamp),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _addEntry, child: const Text('Log')),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: entriesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Could not load basal log: $error')),
            data: (entries) {
              if (entries.isEmpty) {
                return const Center(child: Text('No basal doses logged yet.'));
              }
              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    leading: const Icon(Icons.schedule_outlined),
                    title: Text('${entry.units.toStringAsFixed(2)} units'),
                    subtitle: Text(_timestampFormat.format(entry.timestamp)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(basalEntriesProvider.notifier).remove(entry.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
