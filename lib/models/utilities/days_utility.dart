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
  static final Map<int, WeekDay> NumberToWeekDay = {
    1: WeekDay.monday,
    2: WeekDay.tuesday,
    3: WeekDay.wednesday,
    4: WeekDay.thursday,
    5: WeekDay.friday,
    6: WeekDay.saturday,
    7: WeekDay.sunday,
  };

  static final Map<WeekDay, String> weekDayToSign = {
    WeekDay.monday: 'MO',
    WeekDay.tuesday: 'TU',
    WeekDay.wednesday: 'WE',
    WeekDay.thursday: 'TH',
    WeekDay.friday: 'FR',
    WeekDay.saturday: 'SA',
    WeekDay.sunday: 'SU',
  };

  static final Map<WeekDay, String> weekDayToAbrev = {
    WeekDay.monday: 'Mon',
    WeekDay.tuesday: 'Tue',
    WeekDay.wednesday: 'Wed',
    WeekDay.thursday: 'Thu',
    WeekDay.friday: 'Fri',
    WeekDay.saturday: 'Sat',
    WeekDay.sunday: 'Sun',
  };

  static final Map<int, String> NumberToSign = {
    1: 'MO',
    2: 'TU',
    3: 'WE',
    4: 'TH',
    5: 'FR',
    6: 'SA',
    7: 'SU',
  };
}
