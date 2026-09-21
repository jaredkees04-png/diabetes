enum StatsPeriod { day, week, month }

/// A half-open range: [start, endExclusive). Both are midnight-aligned.
class DateRange {
  const DateRange({required this.start, required this.endExclusive});

  final DateTime start;
  final DateTime endExclusive;

  bool contains(DateTime t) => !t.isBefore(start) && t.isBefore(endExclusive);
}

/// The [period]-sized range containing [anchor]. Weeks run Monday–Sunday.
DateRange rangeFor(StatsPeriod period, DateTime anchor) {
  final day = DateTime(anchor.year, anchor.month, anchor.day);
  switch (period) {
    case StatsPeriod.day:
      return DateRange(start: day, endExclusive: day.add(const Duration(days: 1)));
    case StatsPeriod.week:
      final monday = day.subtract(Duration(days: day.weekday - 1));
      return DateRange(start: monday, endExclusive: monday.add(const Duration(days: 7)));
    case StatsPeriod.month:
      final firstOfMonth = DateTime(anchor.year, anchor.month, 1);
      final firstOfNextMonth = DateTime(anchor.year, anchor.month + 1, 1);
      return DateRange(start: firstOfMonth, endExclusive: firstOfNextMonth);
  }
}

/// Moves [anchor] by one [period] in [direction] (+1 forward, -1 back).
DateTime shiftAnchor(StatsPeriod period, DateTime anchor, int direction) {
  switch (period) {
    case StatsPeriod.day:
      return anchor.add(Duration(days: direction));
    case StatsPeriod.week:
      return anchor.add(Duration(days: 7 * direction));
    case StatsPeriod.month:
      return DateTime(anchor.year, anchor.month + direction, anchor.day);
  }
}
