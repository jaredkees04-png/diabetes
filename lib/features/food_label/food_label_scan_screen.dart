import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../domain/models/food_label.dart';

const _uuid = Uuid();

class FoodLabelScanScreen extends ConsumerStatefulWidget {
  const FoodLabelScanScreen({super.key});

  @override
  ConsumerState<FoodLabelScanScreen> createState() => _FoodLabelScanScreenState();
}

enum _Status { pickingImage, recognizing, ready, error }

class _FoodLabelScanScreenState extends ConsumerState<FoodLabelScanScreen> {
  final _nameController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _carbsController = TextEditingController();
  final _sugarsController = TextEditingController();

  Uint8List? _imageBytes;
  _Status? _status;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _carbsController.dispose();
    _sugarsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndScan() async {
    setState(() {
      _status = _Status.pickingImage;
      _errorMessage = null;
    });

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    final XFile? file = picked ?? await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) {
      setState(() => _status = null);
      return;
    }

    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _status = _Status.recognizing;
    });

    try {
      final rawText = await ref.read(labelOcrServiceProvider).recognizeText(bytes);
      final reading = ref.read(nutritionLabelParserProvider).parse(rawText);
      setState(() {
        _servingSizeController.text = reading.servingSizeText ?? '';
        _carbsController.text = reading.carbsPerServing?.toString() ?? '';
        _sugarsController.text = reading.sugarsPerServing?.toString() ?? '';
        _status = _Status.ready;
      });
    } catch (error) {
      setState(() {
        _status = _Status.error;
        _errorMessage = 'Could not read the label automatically ($error). '
            'You can still enter the numbers by hand below.';
      });
    }
  }

  Future<void> _save() async {
    final imageBytes = _imageBytes;
    final carbs = double.tryParse(_carbsController.text);
    if (imageBytes == null || carbs == null) return;

    final name = _nameController.text.trim();
    final sugars = double.tryParse(_sugarsController.text);
    final servingSize = _servingSizeController.text.trim();

    await ref.read(foodLabelsProvider.notifier).add(
          FoodLabel(
            id: _uuid.v4(),
            name: name.isEmpty ? 'Food label' : name,
            servingSizeText: servingSize.isEmpty ? null : servingSize,
            carbsPerServing: carbs,
            sugarsPerServing: sugars,
            imageBytes: imageBytes,
            createdAt: DateTime.now(),
          ),
        );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final carbs = double.tryParse(_carbsController.text);
    final canSave = _imageBytes != null && carbs != null && _status != _Status.recognizing;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan food label')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageBytes == null)
              OutlinedButton.icon(
                onPressed: _status == _Status.pickingImage ? null : _pickAndScan,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take or choose a photo of the label'),
              )
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(_imageBytes!, fit: BoxFit.contain, height: 220),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _status == _Status.recognizing ? null : _pickAndScan,
                icon: const Icon(Icons.refresh),
                label: const Text('Retake photo'),
              ),
            ],
            if (_status == _Status.recognizing) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(child: Text('Reading the label…')),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (_imageBytes != null && _status != _Status.recognizing) ...[
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name (e.g. \'Peanut butter\')',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _servingSizeController,
                decoration: const InputDecoration(
                  labelText: 'Serving size',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _carbsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Carbs per serving (g)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _sugarsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Sugars per serving (g) — optional',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: canSave ? _save : null,
                child: const Text('Save label'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
