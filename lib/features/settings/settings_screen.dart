import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/dose_settings.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _carbRatioController = TextEditingController();
  final _correctionFactorController = TextEditingController();
  final _targetGlucoseController = TextEditingController();
  double _roundingIncrement = DoseSettings.defaults.roundingIncrement;

  bool _initialized = false;

  @override
  void dispose() {
    _carbRatioController.dispose();
    _correctionFactorController.dispose();
    _targetGlucoseController.dispose();
    super.dispose();
  }

  void _populateFrom(DoseSettings settings) {
    _carbRatioController.text = settings.carbRatio.toString();
    _correctionFactorController.text = settings.correctionFactor.toString();
    _targetGlucoseController.text = settings.targetGlucose.toString();
    _roundingIncrement = settings.roundingIncrement;
  }

  Future<void> _save() async {
    final carbRatio = double.tryParse(_carbRatioController.text);
    final correctionFactor = double.tryParse(_correctionFactorController.text);
    final targetGlucose = double.tryParse(_targetGlucoseController.text);
    if (carbRatio == null || correctionFactor == null || targetGlucose == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid numbers for every field.')),
      );
      return;
    }

    await ref.read(doseSettingsProvider.notifier).update(
          DoseSettings(
            carbRatio: carbRatio,
            correctionFactor: correctionFactor,
            targetGlucose: targetGlucose,
            roundingIncrement: _roundingIncrement,
          ),
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(doseSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Could not load settings: $error')),
      data: (settings) {
        if (!_initialized) {
          _populateFrom(settings);
          _initialized = true;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _carbRatioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Insulin-to-carb ratio (g per unit)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _correctionFactorController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Correction factor (mg/dL per unit)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _targetGlucoseController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Target glucose (mg/dL)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Text('Dose-rounding increment', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<double>(
                segments: kRoundingIncrements
                    .map((step) => ButtonSegment(value: step, label: Text('$step u')))
                    .toList(),
                selected: {_roundingIncrement},
                onSelectionChanged: (selection) =>
                    setState(() => _roundingIncrement = selection.first),
              ),
              const SizedBox(height: 24),
              FilledButton(onPressed: _save, child: const Text('Save settings')),
            ],
          ),
        );
      },
    );
  }
}
