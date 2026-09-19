import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/bolus_calculation.dart';

class BolusScreen extends ConsumerStatefulWidget {
  const BolusScreen({super.key});

  @override
  ConsumerState<BolusScreen> createState() => _BolusScreenState();
}

class _BolusScreenState extends ConsumerState<BolusScreen> {
  final _carbsController = TextEditingController();
  final _glucoseController = TextEditingController();
  BolusCalculation? _result;

  @override
  void dispose() {
    _carbsController.dispose();
    _glucoseController.dispose();
    super.dispose();
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
    });
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
                decoration: const InputDecoration(
                  labelText: 'Carbs (g)',
                  border: OutlineInputBorder(),
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
              if (_result != null) _BolusResultCard(result: _result!),
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
