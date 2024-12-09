  import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/logic/compare_time.dart';

List<Habit> sortHabits(List<Habit> habitList) {
    List<Habit> sortedList = List.from(habitList)
      ..sort((a, b) => (a.timeOfTheDay == null && b.timeOfTheDay == null)
          ? (a.orderIndex.compareTo(b.orderIndex))
          : compareTimeOfDay(a.timeOfTheDay, b.timeOfTheDay));
    return sortedList;
  }