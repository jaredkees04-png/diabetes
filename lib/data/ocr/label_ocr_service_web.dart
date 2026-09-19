import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'label_ocr_service.dart';

@JS('Tesseract.recognize')
external JSPromise<JSAny?> _tesseractRecognize(JSString image, JSString lang);

extension type _RecognizeResult(JSObject _) implements JSObject {
  external _RecognizeData get data;
}

extension type _RecognizeData(JSObject _) implements JSObject {
  external JSString? get text;
}

LabelOcrService createLabelOcrService() => WebLabelOcrService();

/// Loads Tesseract.js on first use and runs OCR fully client-side (WASM) —
/// the label photo never leaves the browser. The script is fetched lazily
/// rather than on every page load, since most sessions never scan a label.
class WebLabelOcrService implements LabelOcrService {
  static const _scriptUrl = 'https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js';

  static bool _scriptLoaded = false;
  static Future<void>? _loadingFuture;

  Future<void> _ensureLoaded() {
    if (_scriptLoaded) return Future.value();
    return _loadingFuture ??= _loadScript();
  }

  Future<void> _loadScript() {
    final completer = Completer<void>();
    final script = web.HTMLScriptElement()
      ..src = _scriptUrl
      ..type = 'application/javascript';
    script.onload = (JSAny _) {
      _scriptLoaded = true;
      if (!completer.isCompleted) completer.complete();
    }.toJS;
    script.onerror = (JSAny _) {
      if (!completer.isCompleted) {
        completer.completeError(
          StateError('Could not load the OCR library — check your internet connection.'),
        );
      }
    }.toJS;
    web.document.head!.appendChild(script);
    return completer.future;
  }

  @override
  Future<String> recognizeText(Uint8List imageBytes) async {
    await _ensureLoaded();
    final dataUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
    final promise = _tesseractRecognize(dataUrl.toJS, 'eng'.toJS);
    final result = _RecognizeResult((await promise.toDart) as JSObject);
    return result.data.text?.toDart ?? '';
  }
}
