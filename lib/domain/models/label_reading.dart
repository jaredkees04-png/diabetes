/// Best-guess numbers pulled from OCR text off a nutrition label. Always
/// shown to the user for confirmation/editing before saving — OCR on a
/// real-world label photo (glare, angle, curved packaging) is unreliable
/// enough that this is a starting point, not a final answer.
class LabelReading {
  const LabelReading({this.carbsPerServing, this.sugarsPerServing, this.servingSizeText});

  final double? carbsPerServing;
  final double? sugarsPerServing;
  final String? servingSizeText;
}
