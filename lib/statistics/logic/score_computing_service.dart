import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/global/logic/num_extent.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/recap/data/daily_recap_repository.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';

// # Basic & habit stats
double? completionComputing(List<DateTime> dates, ref, {String? reference}) {
  int totalToValidate = 0;
  int totalValidated = 0;

  for (DateTime date in dates) {
    List<Habit> targetHabits =
        _fetchTargetHabits(date, ref, reference: reference);
    List<TrackedDay> todayTrackedDays =
        _fetchTargetTrackedDays(targetHabits, date, ref);
    totalToValidate += targetHabits.length;
    totalValidated += todayTrackedDays.length;
  }

  return totalToValidate != 0 ? totalValidated / totalToValidate * 100 : null;
}

List<Habit> _fetchTargetHabits(DateTime date, ref, {String? reference}) {
  List<Habit> targetHabits = [];
  Habit? habit;

  if (reference != null) {
    habit = ref.read(habitProvider.notifier).getHabitById(reference);
  }

  if (reference != null && habit != null) {
    bool trackingStatus = HabitNotifier.getHabitTrackingStatus(habit, date);
    targetHabits = trackingStatus ? [habit] : [];
  } else if (reference != null && habit == null) {
    targetHabits = [];
  } else if (reference == null) {
    targetHabits = ref.watch(habitProvider.notifier).getTodayHabit(date);
  }

  return targetHabits;
}

List<TrackedDay> _fetchTargetTrackedDays(
    List<Habit> targetHabits, DateTime date, ref) {
  List<String> todayHabitIds = targetHabits.map((h) => h.habitId).toList();

  List<TrackedDay> todayTrackedDays = ref
      .watch(trackedDayProvider)
      .where((t) =>
          date == t.date &&
          todayHabitIds.contains(t.habitId) &&
          t.done == Validated.yes)
      .toList();

  return todayTrackedDays;
}

String completionComputingFormatted(List<DateTime> dates, ref,
    {String? reference}) {
  double? completion = completionComputing(dates, ref, reference: reference);
  return completion != null ? '${completion.roundNum()}%' : '-';
}

double? evalutationComputing(List<DateTime> dates, ref, {String? reference}) {
  const List<int> scoresMultiplier = [1, 2, 4, 8, 16];
  double maximumScore = 0;
  double actualScore = 0;

  for (DateTime date in dates) {
    List<Habit> targetHabits =
        _fetchTargetHabits(date, ref, reference: reference);
    List<TrackedDay> todayTrackedDays =
        _fetchTargetTrackedDays(targetHabits, date, ref);

    maximumScore += targetHabits.fold(
        0, (total, habit) => total + scoresMultiplier[habit.ponderation - 1]);

    for (TrackedDay trackedDay in todayTrackedDays) {
      Habit habit =
          targetHabits.firstWhere((h) => h.habitId == trackedDay.habitId);
      actualScore += (scoresMultiplier[habit.ponderation - 1] *
          (trackedDay.totalRating() ?? 10) /
          10);
    }
  }

  // Compute the ratio
  final double? notation =
      maximumScore != 0 ? actualScore / maximumScore * 10 : null;
  return notation;
}

String evalutationComputingFormatted(List<DateTime> dates, ref,
    {String? reference}) {
  double? notation = evalutationComputing(dates, ref, reference: reference);
  return notation != null ? '${notation.roundNum()}/10' : '-';
}

int getCurrentStreak(DateTime date, Habit habit, ref,
    {DateTime? endDate, bool score = false}) {
  int streak = score ? 0 : -1;

  List<TrackedDay> habitPastTrackedDays = ref
      .read(trackedDayProvider)
      .where((TrackedDay t) =>
          t.habitId == habit.habitId &&
          (score
              ? t.dateOnValidation!.isBefore(t.date.add(Duration(days: 7)))
              : true) &&
          t.done == Validated.yes &&
          (endDate != null
              ? (t.date.isAfter(endDate) || t.date.isAtSameMomentAs(endDate))
              : true) &&
          (t.date.isBefore(date) || t.date.isAtSameMomentAs(date)))
      .toList();

  habitPastTrackedDays.sort((a, b) {
    return a.date.isAfter(b.date) ? -1 : 1;
  });

  DateTime start = date;

  for (TrackedDay trackeDay in habitPastTrackedDays) {
    start = DateTime(start.year, start.month, start.day);
    if (!habitPastTrackedDays.map((e) => e.date).contains(start)) break;
    if (trackeDay.date != start) continue;
    streak += 1;
    start = trackeDay.date.subtract(const Duration(days: 1));
    while (!habit.weekdays
        .map(
          (e) => DaysOfTheWeekUtility.weekDayToNumber[e],
        )
        .contains(start.weekday)) {
      start = start.subtract(const Duration(days: 1));
    }
  }
  return streak > 0 ? streak : 0;
}

String streakComputingFormatted(DateTime date, Habit habit, ref) {
  int streak = getCurrentStreak(date, habit, ref);
  return streak >= 0 ? streak.toString() : '-';
}

int? sumStreaksComputing(List<DateTime> dates, ref, {String? reference}) {
  int totalStreaks = 0;
  int totalHabit = 0;

  // Get the active habits and tracked days of the period
  for (DateTime date in dates) {
    List<Habit> targetHabits =
        _fetchTargetHabits(date, ref, reference: reference);
    for (Habit h in targetHabits) {
      totalStreaks += getCurrentStreak(date, h, ref);
    }
    totalHabit += targetHabits.length;
  }

  return totalHabit != 0 ? totalStreaks : null;
}

String sumStreaksComputingFormatted(List<DateTime> dates, ref,
    {String? reference}) {
  int? sumStreaks = sumStreaksComputing(dates, ref, reference: reference);
  return sumStreaks != null ? sumStreaks.toString() : '-';
}

int? totalHabitCompletedComputing(List<DateTime> dates, ref,
    {String? reference}) {
  int totalCompleted = 0;
  int totalMaxCompleted = 0;

  // Get the active habits and tracked days of the period
  for (DateTime date in dates) {
    List<Habit> targetHabits =
        _fetchTargetHabits(date, ref, reference: reference);
    List<TrackedDay> todayTrackedDays =
        _fetchTargetTrackedDays(targetHabits, date, ref);
    totalMaxCompleted += targetHabits.length;
    totalCompleted += todayTrackedDays.length;
  }

  return totalMaxCompleted != 0 ? totalCompleted : null;
}

String totalHabitCompletedComputingFormatted(List<DateTime> dates, ref,
    {String? reference}) {
  int? totalCompleted =
      totalHabitCompletedComputing(dates, ref, reference: reference);
  return totalCompleted != null ? totalCompleted.toString() : '-';
}

double? productivityScoreComputing(List<DateTime> dates, ref,
    {String? reference, DateTime? endDate}) {
  double totalScore = 0;
  int totalHabit = 0;

  // Get the active habits and tracked days of the period
  for (DateTime date in dates) {
    double ponderation = 1;
    double dailyScore = 0;
    List<Habit> targetHabits = _fetchTargetHabits(date, ref);

    targetHabits.sort((a, b) => b.ponderation.compareTo(a.ponderation));
    for (Habit h in targetHabits) {
      dailyScore += getCurrentStreak(date, h, ref,
              endDate: endDate, score: true) *
          ponderation;
      ponderation *= 0.75;
    }
    totalScore += dailyScore;
    totalHabit += targetHabits.length;
  }

  return totalHabit != 0 ? totalScore : null;
}

String productivityScoreComputingFormatted(List<DateTime> dates, ref,
    {String? reference, DateTime? endDate}) {
 double? score = productivityScoreComputing(dates, ref,
      reference: reference, endDate: endDate);
  return score != null ? score.roundNum().toString() : '-';
}

// Custom stats
(double?, int) _additionalMetricsSumLenght(List<DateTime> dates, WidgetRef ref,
    {required (String, String) reference}) {
  List<dynamic> result = [];
  Habit habit =
      ref.watch(habitProvider).firstWhere((h) => h.habitId == reference.$1);

  if (habit.validationType == HabitType.recapDay) {
    final List<RecapDay> recapDays = ref.watch(recapDayProvider);
    for (DateTime date in dates) {
      final RecapDay? recapDay =
          recapDays.firstWhereOrNull((td) => td.date == date);
      if (recapDay != null) {
        double? convertedMetric =
            double.tryParse(recapDay.additionalMetrics?[reference.$2] ?? '');
        if (convertedMetric != null) {
          result.add(convertedMetric);
        }
      }
    }
  } else {
    final List<TrackedDay> trackedDays = ref.watch(trackedDayProvider);
    for (DateTime date in dates) {
      final TrackedDay? trackedDay = trackedDays.firstWhereOrNull(
          (td) => td.habitId == habit.habitId && td.date == date);
      if (trackedDay != null) {
        double? convertedMetric =
            double.tryParse(trackedDay.additionalMetrics?[reference.$2] ?? '');
        if (convertedMetric != null) {
          result.add(convertedMetric);
        }
      }
    }
  }
  return result.isNotEmpty
      ? (result.reduce((a, b) => a + b), result.length)
      : (null, 0);
}

double? additionalMetricsSum(List<DateTime> dates, ref,
    {required (String, String) reference}) {
  return _additionalMetricsSumLenght(dates, ref, reference: reference).$1;
}

String addtionalMetricsSumFormatted(List<DateTime> dates, ref,
    {required (String, String) reference}) {
  double? sum =
      _additionalMetricsSumLenght(dates, ref, reference: reference).$1;
  return sum != null ? sum.roundNum(decimal: 2) : '-';
}

double? edditionalMetricsAverage(List<DateTime> dates, ref,
    {required (String, String) reference}) {
  (double?, int) result =
      _additionalMetricsSumLenght(dates, ref, reference: reference);
  return result.$1 != null ? result.$1! / result.$2 : null;
}

String additionalMetricsAverageFormatted(List<DateTime> dates, ref,
    {required (String, String) reference}) {
  double? average = edditionalMetricsAverage(dates, ref, reference: reference);
  return average != null ? average.roundNum(decimal: 2) : '-';
}

double? emotionAverage(List<DateTime> dates, ref, {required String reference}) {
  List<dynamic> result = [];

  final List<RecapDay> recapDays = ref.watch(recapDayProvider);

  for (DateTime date in dates) {
    final RecapDay? recapDay =
        recapDays.firstWhereOrNull((td) => td.date == date);
    if (recapDay != null) {
      double emotionValue = recapDay.getProperty(reference) ?? 0;
      result.add(emotionValue.toDouble());
    }
  }
  return result.isNotEmpty
      ? result.reduce((a, b) => a + b) / result.length
      : null;
}

String emotionAverageFormatted(List<DateTime> dates, ref,
    {required String reference}) {
  double? average = emotionAverage(dates, ref, reference: reference);
  return average != null ? '${average.roundNum().toString()}/5' : '-';
}
