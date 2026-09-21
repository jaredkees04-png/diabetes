import 'package:flutter_test/flutter_test.dart';

import 'package:dose_glucose_log/core/utils/relative_time.dart';

void main() {
  final now = DateTime(2026, 9, 21, 12, 0, 0);

  test('formats sub-minute as Just now', () {
    expect(relativeTime(now.subtract(const Duration(seconds: 30)), now: now), 'Just now');
  });

  test('formats minutes', () {
    expect(relativeTime(now.subtract(const Duration(minutes: 5)), now: now), '5m ago');
  });

  test('formats hours', () {
    expect(relativeTime(now.subtract(const Duration(hours: 3)), now: now), '3h ago');
  });

  test('formats days', () {
    expect(relativeTime(now.subtract(const Duration(days: 2)), now: now), '2d ago');
  });
}
