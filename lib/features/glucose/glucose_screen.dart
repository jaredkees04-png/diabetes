import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../domain/models/glucose_entry.dart';

const _uuid = Uuid();
final _timestampFormat = DateFormat('MMM d, y • h:mm a');

class GlucoseScreen extends ConsumerStatefulWidget {
  const GlucoseScreen({super.key});

  @override
  ConsumerState<GlucoseScreen> createState() => _GlucoseScreenState();
}

class _GlucoseScreenState extends ConsumerState<GlucoseScreen> {
  final _readingController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _timestamp = DateTime.now();

  @override
  void dispose() {
    _readingController.dispose();
    _noteController.dispose();
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
      _timestamp = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _addEntry() async {
    final reading = double.tryParse(_readingController.text);
    if (reading == null) return;

    final note = _noteController.text.trim();
    await ref.read(glucoseEntriesProvider.notifier).add(
          GlucoseEntry(
            id: _uuid.v4(),
            reading: reading,
            timestamp: _timestamp,
            note: note.isEmpty ? null : note,
          ),
        );
    _readingController.clear();
    _noteController.clear();
    setState(() => _timestamp = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(glucoseEntriesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _readingController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Reading (mg/dL)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _pickTimestamp,
                  icon: const Icon(Icons.schedule),
                  label: Text(
                    _timestampFormat.format(_timestamp),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(),
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
            error: (error, _) => Center(child: Text('Could not load glucose log: $error')),
            data: (entries) {
              if (entries.isEmpty) {
                return const Center(child: Text('No glucose readings logged yet.'));
              }
              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return ListTile(
                    leading: _FlagIcon(entry: entry),
                    title: Text('${entry.reading.toStringAsFixed(0)} mg/dL'),
                    subtitle: Text(
                      entry.note == null
                          ? _timestampFormat.format(entry.timestamp)
                          : '${_timestampFormat.format(entry.timestamp)}\n${entry.note}',
                    ),
                    isThreeLine: entry.note != null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(glucoseEntriesProvider.notifier).remove(entry.id),
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

class _FlagIcon extends StatelessWidget {
  const _FlagIcon({required this.entry});

  final GlucoseEntry entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (entry.isLow) {
      return Icon(Icons.arrow_downward, color: colorScheme.error);
    }
    if (entry.isHigh) {
      return Icon(Icons.arrow_upward, color: colorScheme.error);
    }
    return const Icon(Icons.check_circle_outline);
  }
}
