  bool isInTheWeek(DateTime date1, DateTime? date2, List<DateTime> offsetWeekDays) {
    final startBeforeEndOfWeek = date1.isBefore(offsetWeekDays.last) ||
        date1.isAtSameMomentAs(offsetWeekDays.last);
    final endAfterStartOfWeek = date2 == null ||
        date2.isAfter(offsetWeekDays.first) ||
        date2.isAtSameMomentAs(offsetWeekDays.first);

    return startBeforeEndOfWeek && endAfterStartOfWeek;
  }