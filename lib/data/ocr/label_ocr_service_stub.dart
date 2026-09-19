import 'dart:typed_data';

import 'label_ocr_service.dart';

LabelOcrService createLabelOcrService() => _UnsupportedLabelOcrService();

class _UnsupportedLabelOcrService implements LabelOcrService {
  @override
  Future<String> recognizeText(Uint8List imageBytes) {
    throw UnsupportedError('Label scanning is only available in the web build right now.');
  }
}
