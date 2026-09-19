import 'package:flutter/material.dart';

import '../../domain/models/food_label.dart';

class FoodLabelUseScreen extends StatefulWidget {
  const FoodLabelUseScreen({super.key, required this.label});

  final FoodLabel label;

  @override
  State<FoodLabelUseScreen> createState() => _FoodLabelUseScreenState();
}

class _FoodLabelUseScreenState extends State<FoodLabelUseScreen> {
  final _servingsController = TextEditingController(text: '1');

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label;
    final servings = double.tryParse(_servingsController.text) ?? 0;
    final totalCarbs = label.carbsPerServing * servings;
    final totalSugars = label.sugarsPerServing == null ? null : label.sugarsPerServing! * servings;

    return Scaffold(
      appBar: AppBar(title: Text(label.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(label.imageBytes, fit: BoxFit.contain, height: 220),
            ),
            const SizedBox(height: 12),
            if (label.servingSizeText != null) Text('Serving size: ${label.servingSizeText}'),
            Text('Carbs per serving: ${label.carbsPerServing.toStringAsFixed(1)} g'),
            if (label.sugarsPerServing != null)
              Text('Sugars per serving: ${label.sugarsPerServing!.toStringAsFixed(1)} g'),
            const SizedBox(height: 16),
            TextField(
              controller: _servingsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Servings eaten',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Total carbs', style: Theme.of(context).textTheme.labelLarge),
                    Text(
                      '${totalCarbs.toStringAsFixed(1)} g',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (totalSugars != null) ...[
                      const SizedBox(height: 4),
                      Text('Total sugars: ${totalSugars.toStringAsFixed(1)} g'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: servings > 0 ? () => Navigator.pop(context, totalCarbs) : null,
              child: const Text('Use this amount'),
            ),
          ],
        ),
      ),
    );
  }
}
