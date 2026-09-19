import 'dart:typed_data';

import 'label_ocr_service_stub.dart' if (dart.library.js_interop) 'label_ocr_service_web.dart' as impl;

/// Runs OCR on a nutrition label photo. The web implementation uses
/// Tesseract.js, which does the recognition entirely client-side in the
/// browser via WebAssembly — the photo is never sent anywhere.
abstract class LabelOcrService {
  Future<String> recognizeText(Uint8List imageBytes);
}

LabelOcrService createLabelOcrService() => impl.createLabelOcrService();
