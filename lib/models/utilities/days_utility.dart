enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class DaysUtility {
  static final Map<WeekDay, int> weekDayToNumber = {
    WeekDay.monday: 1,
    WeekDay.tuesday: 2,
    WeekDay.wednesday: 3,
    WeekDay.thursday: 4,
    WeekDay.friday: 5,
    WeekDay.saturday: 6,
    WeekDay.sunday: 7,
  };

  static final Map<WeekDay, String> weekDayToSign = {
    WeekDay.monday: 'M',
    WeekDay.tuesday: 'T',
    WeekDay.wednesday: 'W',
    WeekDay.thursday: 'Th',
    WeekDay.friday: 'F',
    WeekDay.saturday: 'S',
    WeekDay.sunday: 'Su',
  };
}
