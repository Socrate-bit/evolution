  import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/utilities/compare_time_of_day.dart';

List<Habit> sortHabits(List<Habit> habitList) {
    List<Habit> sortedList = List.from(habitList)
      ..sort((a, b) => (a.timeOfTheDay == null && b.timeOfTheDay == null)
          ? (a.orderIndex.compareTo(b.orderIndex))
          : compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));
    return sortedList;
  }