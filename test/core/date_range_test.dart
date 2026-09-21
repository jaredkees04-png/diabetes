import 'package:flutter_test/flutter_test.dart';

import 'package:dose_glucose_log/core/utils/date_range.dart';

void main() {
  group('rangeFor', () {
    test('day is midnight to midnight the next day', () {
      final range = rangeFor(StatsPeriod.day, DateTime(2026, 9, 21, 14, 30));
      expect(range.start, DateTime(2026, 9, 21));
      expect(range.endExclusive, DateTime(2026, 9, 22));
    });

    test('week starts Monday and ends the following Monday', () {
      // Sep 21 2026 is a Monday, Sep 24 a Thursday.
      final range = rangeFor(StatsPeriod.week, DateTime(2026, 9, 24));
      expect(range.start, DateTime(2026, 9, 21));
      expect(range.endExclusive, DateTime(2026, 9, 28));
    });

    test('week anchored on a Sunday still belongs to the prior Monday', () {
      // Sep 27 2026 is a Sunday, the last day of that Mon-Sun week.
      final range = rangeFor(StatsPeriod.week, DateTime(2026, 9, 27));
      expect(range.start, DateTime(2026, 9, 21));
      expect(range.endExclusive, DateTime(2026, 9, 28));
    });

    test('month spans the whole calendar month', () {
      final range = rangeFor(StatsPeriod.month, DateTime(2026, 9, 15));
      expect(range.start, DateTime(2026, 9, 1));
      expect(range.endExclusive, DateTime(2026, 10, 1));
    });

    test('month range across a year boundary', () {
      final range = rangeFor(StatsPeriod.month, DateTime(2026, 12, 5));
      expect(range.start, DateTime(2026, 12, 1));
      expect(range.endExclusive, DateTime(2027, 1, 1));
    });

    test('contains is inclusive of start and exclusive of end', () {
      final range = rangeFor(StatsPeriod.day, DateTime(2026, 9, 21));
      expect(range.contains(DateTime(2026, 9, 21, 0, 0)), isTrue);
      expect(range.contains(DateTime(2026, 9, 21, 23, 59)), isTrue);
      expect(range.contains(DateTime(2026, 9, 22, 0, 0)), isFalse);
    });
  });

  group('shiftAnchor', () {
    test('day shifts by one day', () {
      expect(shiftAnchor(StatsPeriod.day, DateTime(2026, 9, 21), 1), DateTime(2026, 9, 22));
      expect(shiftAnchor(StatsPeriod.day, DateTime(2026, 9, 21), -1), DateTime(2026, 9, 20));
    });

    test('week shifts by seven days', () {
      expect(shiftAnchor(StatsPeriod.week, DateTime(2026, 9, 21), 1), DateTime(2026, 9, 28));
    });

    test('month shifts by one month, including year rollover', () {
      expect(shiftAnchor(StatsPeriod.month, DateTime(2026, 12, 15), 1), DateTime(2027, 1, 15));
      expect(shiftAnchor(StatsPeriod.month, DateTime(2027, 1, 15), -1), DateTime(2026, 12, 15));
    });
  });
}
