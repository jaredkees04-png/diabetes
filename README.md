# Dose & Glucose Log

A personal, on-device diabetes management tool built with Flutter. Seven screens:

- **Home** — a quick-glance dashboard: your latest glucose reading (flagged
  if high/low), today's basal and bolus totals, readings/average/high-low
  counts for today, and a merged recent-activity feed of your basal, bolus,
  and glucose logs. Nothing here is stored separately — it's all computed
  on the fly from the same logs the Basal, Bolus, and Glucose screens
  write to.
- **History** — browse your logs by day, week, or month. Each period shows
  aggregate stats (total basal, total bolus, reading count/average,
  high/low count). Day view lists every entry logged that day; Week and
  Month views show a day-by-day breakdown you can tap into to jump
  straight to that day. Step forward/back a period at a time, jump back
  to today, or use the date picker to go straight to any day.
- **Bolus** — enter carbs and current glucose; calculates
  `dose = (carbs ÷ insulin-to-carb ratio) + (glucose − target) ÷ correction factor`,
  rounded to your configured increment. Shows the full breakdown, not just
  the final number, and warns when glucose is below target or when no
  bolus is indicated. Carbs can also be pulled in from a saved food label
  (see below) via the camera icon on the Carbs field. Once you've
  administered the dose, "Log this dose" saves it to your history.
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
- Basal, bolus, glucose, and food-label entries (including label photos)
  use `sqflite` — on web, via `sqflite_common_ffi_web`, which stores into
  the browser's IndexedDB rather than a native sqlite file.
- Settings use `shared_preferences`.

There is no network layer for your data and no cloud sync anywhere in
this app. The one exception is loading the Tesseract.js OCR *library
code* itself from a CDN on first use of the label scanner — the same
trust model as loading any other JS dependency — but the label photo it
processes is never uploaded anywhere; the OCR runs locally in-browser.

> This app only does arithmetic on values your doctor prescribed. It is
> not medical advice — always use your own judgment and consult your
> care team. This disclaimer is shown as a dialog each time the app opens.

## Development

```
flutter pub get
flutter test
flutter run
```
