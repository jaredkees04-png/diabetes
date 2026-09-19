# Dose & Glucose Log

A personal, on-device diabetes management tool built with Flutter. Four screens:

- **Bolus** — enter carbs and current glucose; calculates
  `dose = (carbs ÷ insulin-to-carb ratio) + (glucose − target) ÷ correction factor`,
  rounded to your configured increment. Shows the full breakdown, not just
  the final number, and warns when glucose is below target or when no
  bolus is indicated.
- **Basal** — log units + timestamp.
- **Glucose** — log a reading + timestamp + optional note; flags readings
  ≤70 or ≥180.
- **Settings** — insulin-to-carb ratio, correction factor, target glucose,
  and dose-rounding increment (0.1 / 0.5 / 1 unit).

All data is stored locally on-device only:
- Basal and glucose logs use `sqflite`.
- Settings use `shared_preferences`.

There is no network layer and no cloud sync anywhere in this app.

> This app only does arithmetic on values your doctor prescribed. It is
> not medical advice — always use your own judgment and consult your
> care team. A persistent disclaimer is shown on every screen.

## Development

```
flutter pub get
flutter test
flutter run
```
