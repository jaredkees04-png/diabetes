import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/models/food_label.dart';
import 'food_label_scan_screen.dart';
import 'food_label_use_screen.dart';

/// Browses saved food labels. In [pickerMode] (opened from the Bolus
/// screen), tapping a label walks through the servings calculator and
/// then pops this whole screen with the resulting carbs total, so the
/// caller can `await Navigator.push<double>(...)` it directly.
class FoodLabelListScreen extends ConsumerWidget {
  const FoodLabelListScreen({super.key, this.pickerMode = false});

  final bool pickerMode;

  Future<void> _openLabel(BuildContext context, FoodLabel label) async {
    final result = await Navigator.push<double>(
      context,
      MaterialPageRoute(builder: (_) => FoodLabelUseScreen(label: label)),
    );
    if (result != null && pickerMode && context.mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelsAsync = ref.watch(foodLabelsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Food Labels')),
      body: labelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load food labels: $error')),
        data: (labels) {
          if (labels.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No food labels saved yet. Scan one with the button below.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: labels.length,
            itemBuilder: (context, index) {
              final label = labels[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.memory(
                    label.imageBytes,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(label.name),
                subtitle: Text('${label.carbsPerServing.toStringAsFixed(1)} g carbs / serving'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => ref.read(foodLabelsProvider.notifier).remove(label.id),
                ),
                onTap: () => _openLabel(context, label),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodLabelScanScreen()),
          );
        },
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Scan label'),
      ),
    );
  }
}
