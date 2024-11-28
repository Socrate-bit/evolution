class OffsetDays {
  static List<DateTime> getWeekDaysFromOffset(int offSet,
      {DateTime? startDate}) {
    List<DateTime> weekDays = [];
    startDate ??= DateTime.now();
    int dayShift = offSet * 7;
    DateTime shiftedDate = startDate.subtract(Duration(days: dayShift));

    // Compute the start of the week
    DateTime startOfTheWeek =
        shiftedDate.subtract(Duration(days: shiftedDate.weekday - 1));

    // Generate all 7 days of the week
    for (int i = 0; i < 7; i++) {
      DateTime dayOfTheWeek = startOfTheWeek.add(Duration(days: i));
      weekDays.add(
          DateTime(dayOfTheWeek.year, dayOfTheWeek.month, dayOfTheWeek.day));
    }

    return weekDays;
  }

  static List<DateTime> getOffsetMonthDays(int monthShift,
      {DateTime? startDate}) {
    List<DateTime> monthDays = [];
    startDate ??= DateTime.now();

    DateTime startOfTheMonth =
        DateTime(startDate.year, startDate.month - monthShift, 1);
    int targetMonth = startOfTheMonth.month;

    while (startOfTheMonth.month == targetMonth) {
      monthDays.add(DateTime(
          startOfTheMonth.year, startOfTheMonth.month, startOfTheMonth.day));
      startOfTheMonth = startOfTheMonth.add(const Duration(days: 1));
    }

    return monthDays;
  }

  static List<DateTime> getOffsetYearDays(int yearShift) {
    List<DateTime> yearDays = [];
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year - yearShift, 1, 1);

    while (startDate.year == now.year - yearShift) {
      yearDays.add(DateTime(startDate.year, startDate.month, startDate.day));
      startDate = startDate.add(const Duration(days: 1));
    }

    return yearDays;
  }

  static List<DateTime> getOffsetDays(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    DateTime start = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime end = DateTime(endDate.year, endDate.month, endDate.day);

    while (!start.isAfter(end)) {
      days.add(DateTime(start.year, start.month, start.day));
      start = start.add(const Duration(days: 1));
    }

    return days;
  }
}
