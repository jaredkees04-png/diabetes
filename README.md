# Dose & Glucose Log

A personal, on-device diabetes management tool built with Flutter. Five screens:

- **Bolus** — enter carbs and current glucose; calculates
  `dose = (carbs ÷ insulin-to-carb ratio) + (glucose − target) ÷ correction factor`,
  rounded to your configured increment. Shows the full breakdown, not just
  the final number, and warns when glucose is below target or when no
  bolus is indicated. Carbs can also be pulled in from a saved food label
  (see below) via the camera icon on the Carbs field.
- **Basal** — log units + timestamp.
- **Glucose** — log a reading + timestamp + optional note; flags readings
  ≤70 or ≥180.
- **Labels** — scan a nutrition facts label with your camera. OCR
  (Tesseract.js, running entirely client-side in the browser via WASM —
  the photo never leaves your device) tries to read off the carbs/sugars
  per serving and serving size; you confirm or correct whatever it found
  before saving. The photo and numbers are saved for reuse — pick a
  serving count next time and it does the multiplication for you.
- **Settings** — insulin-to-carb ratio, correction factor, target glucose,
  and dose-rounding increment (0.1 / 0.5 / 1 unit).

All data is stored locally on-device only:
- Basal, glucose, and food-label entries (including label photos) use
  `sqflite` — on web, via `sqflite_common_ffi_web`, which stores into the
  browser's IndexedDB rather than a native sqlite file.
- Settings use `shared_preferences`.

There is no network layer for your data and no cloud sync anywhere in
this app. The one exception is loading the Tesseract.js OCR *library
code* itself from a CDN on first use of the label scanner — the same
trust model as loading any other JS dependency — but the label photo it
processes is never uploaded anywhere; the OCR runs locally in-browser.

> This app only does arithmetic on values your doctor prescribed. It is
> not medical advice — always use your own judgment and consult your
> care team. A persistent disclaimer is shown on every screen.

## Development

```
flutter pub get
flutter test
flutter run
```
