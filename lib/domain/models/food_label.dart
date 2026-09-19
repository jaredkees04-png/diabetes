import 'dart:typed_data';

/// A saved food label: its photo plus the per-serving numbers read off it,
/// so it can be reused without re-scanning every time.
class FoodLabel {
  const FoodLabel({
    required this.id,
    required this.name,
    required this.servingSizeText,
    required this.carbsPerServing,
    required this.sugarsPerServing,
    required this.imageBytes,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? servingSizeText;
  final double carbsPerServing;
  final double? sugarsPerServing;
  final Uint8List imageBytes;
  final DateTime createdAt;

  factory FoodLabel.fromMap(Map<String, Object?> map) {
    return FoodLabel(
      id: map['id'] as String,
      name: map['name'] as String,
      servingSizeText: map['serving_size_text'] as String?,
      carbsPerServing: map['carbs_per_serving'] as double,
      sugarsPerServing: map['sugars_per_serving'] as double?,
      imageBytes: map['image_bytes'] as Uint8List,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'serving_size_text': servingSizeText,
      'carbs_per_serving': carbsPerServing,
      'sugars_per_serving': sugarsPerServing,
      'image_bytes': imageBytes,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
}
