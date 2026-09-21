import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../domain/models/bolus_calculation.dart';
import '../../domain/models/bolus_entry.dart';
import '../food_label/food_label_list_screen.dart';

const _uuid = Uuid();

class BolusScreen extends ConsumerStatefulWidget {
  const BolusScreen({super.key});

  @override
  ConsumerState<BolusScreen> createState() => _BolusScreenState();
}

class _BolusScreenState extends ConsumerState<BolusScreen> {
  final _carbsController = TextEditingController();
  final _glucoseController = TextEditingController();
  BolusCalculation? _result;
  bool _logged = false;

  @override
  void dispose() {
    _carbsController.dispose();
    _glucoseController.dispose();
    super.dispose();
  }

  Future<void> _scanFoodLabel() async {
    final carbs = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (_) => const FoodLabelListScreen(pickerMode: true)),
    );
    if (carbs != null) {
      _carbsController.text = carbs.toStringAsFixed(1);
      _calculate();
    }
  }

  void _calculate() {
    final settingsAsync = ref.read(doseSettingsProvider);
    final settings = settingsAsync.value;
    if (settings == null) return;

    final carbs = double.tryParse(_carbsController.text);
    final glucose = double.tryParse(_glucoseController.text);
    if (carbs == null || glucose == null) {
      setState(() => _result = null);
      return;
    }

    final calculator = ref.read(bolusCalculatorProvider);
    setState(() {
      _result = calculator.calculate(
        carbsGrams: carbs,
        currentGlucose: glucose,
        settings: settings,
      );
      _logged = false;
    });
  }

  Future<void> _logDose() async {
    final result = _result;
    final glucose = double.tryParse(_glucoseController.text);
    if (result == null || glucose == null) return;

    await ref.read(bolusEntriesProvider.notifier).add(
          BolusEntry(
            id: _uuid.v4(),
            carbsGrams: double.tryParse(_carbsController.text) ?? 0,
            glucoseAtTime: glucose,
            carbDose: result.carbDose,
            correctionDose: result.correctionDose,
            roundedDose: result.roundedDose,
            timestamp: DateTime.now(),
          ),
        );

    if (!mounted) return;
    setState(() => _logged = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dose logged.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(doseSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Could not load settings: $error')),
      data: (settings) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _carbsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Carbs (g)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.camera_alt_outlined),
                    tooltip: 'Use a saved food label',
                    onPressed: _scanFoodLabel,
                  ),
                ),
                onChanged: (_) => _calculate(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _glucoseController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Current glucose (mg/dL)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _calculate(),
              ),
              const SizedBox(height: 20),
              if (_result != null) ...[
                _BolusResultCard(result: _result!),
                const SizedBox(height: 12),
                if (_logged)
                  const _LoggedIndicator()
                else
                  FilledButton.icon(
                    onPressed: _result!.suggestsNoBolus ? null : _logDose,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Log this dose'),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BolusResultCard extends StatelessWidget {
  const _BolusResultCard({required this.result});

  final BolusCalculation result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Breakdown', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _BreakdownRow(
              label: 'Carb dose (carbs ÷ ratio)',
              value: result.carbDose,
            ),
            _BreakdownRow(
              label: 'Correction dose ((glucose − target) ÷ factor)',
              value: result.correctionDose,
            ),
            const Divider(),
            _BreakdownRow(label: 'Raw total', value: result.rawTotal),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text('Rounded dose', style: theme.textTheme.labelLarge),
                  Text(
                    '${result.roundedDose.toStringAsFixed(2)} units',
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            if (result.isBelowTarget) ...[
              const SizedBox(height: 12),
              _Warning(
                icon: Icons.arrow_downward,
                text: 'Current glucose is below target — the correction '
                    'component is reducing the dose.',
              ),
            ],
            if (result.suggestsNoBolus) ...[
              const SizedBox(height: 8),
              const _Warning(
                icon: Icons.warning_amber_rounded,
                text: 'Based on these numbers, no bolus is needed.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoggedIndicator extends StatelessWidget {
  const _LoggedIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: colorScheme.onPrimaryContainer, size: 18),
          const SizedBox(width: 8),
          Text('Dose logged', style: TextStyle(color: colorScheme.onPrimaryContainer)),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 8),
          Text(value.toStringAsFixed(2)),
        ],
      ),
    );
  }
}

class _Warning extends StatelessWidget {
  const _Warning({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onErrorContainer, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: colorScheme.onErrorContainer)),
          ),
        ],
      ),
    );
  }
}
