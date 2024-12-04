import 'package:tracker_v1/statistics_screen/datas/statistics_model.dart';
import 'package:tracker_v1/models/utilities/offset_days.dart';
import 'package:tracker_v1/statistics_screen/logics/date_utility.dart';
import 'package:tracker_v1/statistics_screen/logics/score_computing_service.dart';

List<String> getContainerStats(
    ref,
    List<Stat> allContainerStats,
    int periodOffSet,
    int selectedPeriodType,
    DateTime? pickedStartDate,
    DateTime? pickedEndDate) {
  List<String> formattedStats = [];
  List<DateTime> daysList = [];

  if (pickedStartDate != null && pickedEndDate != null) {
    daysList = OffsetDays.getOffsetDays(pickedStartDate, pickedEndDate);
  } else {
    switch (selectedPeriodType) {
      case 0:
        daysList = OffsetDays.getWeekDaysFromOffset(periodOffSet)
            .where((e) => !e.isAfter(today))
            .toList();
        break;
      case 1:
        daysList = OffsetDays.getOffsetMonthDays(periodOffSet)
            .where((e) => !e.isAfter(today))
            .toList();

        break;
      default:
        daysList = OffsetDays.getOffsetYearDays(periodOffSet)
            .where((e) => !e.isAfter(today))
            .toList();
        break;
    }
  }
  
  for (Stat stat in allContainerStats) {
    Function statComputingFunction = _getComputationFunction(stat).$2;
    if (statComputingFunction == productivityScoreComputingFormatted && daysList.isNotEmpty) {
      formattedStats.add(statComputingFunction(daysList, ref,
          reference: stat.ref, endDate: daysList.first));
    } else {
      formattedStats
          .add(statComputingFunction(daysList, ref, reference: stat.ref));
    }
  }

  return formattedStats;
}

List<(DateTime, double?)> getGraphData(
  ref,
  Stat seletedStat,
  DateTime? pickedStartDate,
  DateTime? pickedEndate,
  int periodOffSet,
  int selectedPeriodType,
) {
  List<(DateTime, double?)> computedStatsWithDate = [];
  Function statComputingFunction = _getComputationFunction(seletedStat).$1;

  if (pickedStartDate != null && pickedEndate != null) {
    switch (selectedPeriodType) {
      case 0:
        // Initialize the last day
        DateTime targetDay = pickedEndate;

        // Loop until start date
        for (int shift = 0; !targetDay.isBefore(pickedStartDate); shift++) {
          // Update the target day
          targetDay = DateTime(
              pickedEndate.year, pickedEndate.month, pickedEndate.day - shift);

          // Filter the active day
          List<DateTime> targetDayList = [targetDay]
              .where((date) =>
                  date.isBefore(today) &&
                  !date.isBefore(pickedStartDate) &&
                  !date.isAfter(pickedEndate))
              .toList();

          // Compute and add notation
          if (statComputingFunction == productivityScoreComputingFormatted) {
            computedStatsWithDate.add((
              targetDay,
              statComputingFunction(targetDayList, ref,
                      reference: seletedStat.ref, endDate: pickedStartDate)
                  ?.toDouble()
            ));
          } else {
            computedStatsWithDate.add((
              targetDay,
              statComputingFunction(targetDayList, ref,
                      reference: seletedStat.ref)
                  ?.toDouble()
            ));
          }
        }
        break;

      case 1:
        // Initialize the last week
        List<DateTime> targetWeek =
            OffsetDays.getWeekDaysFromOffset(0, startDate: pickedEndate);

        // Loop until start date
        for (int shift = 0;
            !targetWeek.last.isBefore(pickedStartDate);
            shift++) {
          // Update the target week
          targetWeek =
              OffsetDays.getWeekDaysFromOffset(shift, startDate: pickedEndate);

          // Filter the active days
          final filteredTargetWeek = targetWeek
              .where((date) =>
                  date.isBefore(today) &&
                  !date.isBefore(pickedStartDate) &&
                  !date.isAfter(pickedEndate))
              .toList();

          // Compute and add notation
          if (filteredTargetWeek.isNotEmpty) {
            if (statComputingFunction == productivityScoreComputing) {
              computedStatsWithDate.add((
                filteredTargetWeek.first,
                statComputingFunction(filteredTargetWeek, ref,
                        reference: seletedStat.ref, endDate: pickedStartDate)
                    ?.toDouble()
              ));
            } else {
              computedStatsWithDate.add((
                filteredTargetWeek.first,
                statComputingFunction(filteredTargetWeek, ref,
                        reference: seletedStat.ref)
                    ?.toDouble()
              ));
            }
          }
        }
        break;
      default:
        // Initialize the last week
        List<DateTime> targetMonth =
            OffsetDays.getOffsetMonthDays(0, startDate: pickedEndate);

        // Loop until start date
        for (int shift = 0;
            !targetMonth.last.isBefore(pickedStartDate);
            shift++) {
          // Update the target week
          targetMonth =
              OffsetDays.getOffsetMonthDays(shift, startDate: pickedEndate);

          // Filter the active days
          final filteredTargetMonth = targetMonth
              .where((date) =>
                  date.isBefore(today) &&
                  !date.isBefore(pickedStartDate) &&
                  !date.isAfter(pickedEndate))
              .toList();

          // Compute and add notation
          if (filteredTargetMonth.isNotEmpty) {
            if (statComputingFunction == productivityScoreComputing) {
              computedStatsWithDate.add((
                filteredTargetMonth.first,
                statComputingFunction(filteredTargetMonth, ref,
                        reference: seletedStat.ref, endDate: pickedStartDate)
                    ?.toDouble()
              ));
            } else {
              computedStatsWithDate.add((
                filteredTargetMonth.first,
                statComputingFunction(filteredTargetMonth, ref,
                        reference: seletedStat.ref)
                    ?.toDouble()
              ));
            }
          }
        }
        break;
    }
  } else {
    switch (selectedPeriodType) {
      case 0:
        // Initialize the last period
        DateTime startDay = periodOffSet == 0
            ? today
            : OffsetDays.getWeekDaysFromOffset(periodOffSet).last;
        int shift = 0;
        DateTime targetDay =
            DateTime(startDay.year, startDay.month, startDay.day);
        // First period
        DateTime firstDayOfThePeriod =
            OffsetDays.getWeekDaysFromOffset(periodOffSet).first;
        do {
          // Compute and add notation
          List<DateTime> filteredTargetDay =
              [targetDay].where((e) => !e.isAfter(today)).toList();

          if (filteredTargetDay.isNotEmpty) {
            if (statComputingFunction == productivityScoreComputing) {
              computedStatsWithDate.add((
                targetDay,
                statComputingFunction(filteredTargetDay, ref,
                        reference: seletedStat.ref,
                        endDate: firstDayOfThePeriod)
                    ?.toDouble()
              ));
            } else {
              computedStatsWithDate.add((
                targetDay,
                statComputingFunction(filteredTargetDay, ref,
                        reference: seletedStat.ref)
                    ?.toDouble()
              ));
            }
          }
          // Shift the day
          shift++;
          targetDay =
              DateTime(startDay.year, startDay.month, startDay.day - shift);
        } while (targetDay.weekday != 7);
        break;

      case 1:
        // Initialize the last period
        List<DateTime> dayOfTheMonth =
            OffsetDays.getOffsetMonthDays(periodOffSet)
                .where((e) => !e.isAfter(today))
                .toList();

        if (dayOfTheMonth.isEmpty) {
          break;
        }
        DateTime lastDayOfTheMonth = dayOfTheMonth.last;
        List<DateTime> lastWeekOfTheMonth =
            OffsetDays.getWeekDaysFromOffset(0, startDate: lastDayOfTheMonth)
                .where((e) => !e.isAfter(today))
                .toList();
        List<DateTime> targetWeek = lastWeekOfTheMonth;
        int shift = 0;

        do {
          if (targetWeek.isNotEmpty) {
            // Compute and add notation
            if (statComputingFunction == productivityScoreComputing) {
              computedStatsWithDate.add((
                targetWeek.first,
                statComputingFunction(targetWeek, ref,
                        reference: seletedStat.ref,
                        endDate: dayOfTheMonth.first)
                    ?.toDouble()
              ));
            } else {
              computedStatsWithDate.add((
                targetWeek.first,
                statComputingFunction(targetWeek, ref,
                        reference: seletedStat.ref)
                    ?.toDouble()
              ));

            }
          }

          // Shift the day
          shift++;
          targetWeek = OffsetDays.getWeekDaysFromOffset(shift,
              startDate: lastDayOfTheMonth);
        } while (targetWeek.first.month == lastDayOfTheMonth.month &&
            targetWeek.first.year == lastDayOfTheMonth.year);
        break;

      default:
        // Initialize the last period
        DateTime lastDayOfTheYear = DateTime(today.year - periodOffSet, 12);
        List<DateTime> lastMonthOfTheYear =
            OffsetDays.getOffsetMonthDays(0, startDate: lastDayOfTheYear);
        List<DateTime> targetMonth = lastMonthOfTheYear;
        int shift = 0;

        do {
          List<DateTime> targetMonthAfterToday =
              targetMonth.where((e) => !e.isAfter(today)).toList();
          // Compute and add notation
          if (targetMonthAfterToday.isNotEmpty) {
            if (statComputingFunction == productivityScoreComputing) {
              computedStatsWithDate.add((
                targetMonthAfterToday.first,
                statComputingFunction(targetMonthAfterToday, ref,
                        reference: seletedStat.ref,
                        endDate: DateTime(today.year - periodOffSet, 1, 1))
                    ?.toDouble()
              ));
            } else {
              computedStatsWithDate.add((
                targetMonthAfterToday.first,
                statComputingFunction(targetMonthAfterToday, ref,
                        reference: seletedStat.ref)
                    ?.toDouble()
              ));
            }
          }

          // Shift the day
          shift++;
          targetMonth =
              OffsetDays.getOffsetMonthDays(shift, startDate: lastDayOfTheYear);
        } while (targetMonth.first.year == today.year - periodOffSet);
        break;
    }
  }
  return computedStatsWithDate.reversed.toList();
}

(Function, Function) _getComputationFunction(Stat stat) {
  switch (stat.type) {
    case StatType.basic:
      switch (stat.formulaType) {
        case BasicHabitSubtype.score:
          return (
            productivityScoreComputing,
            productivityScoreComputingFormatted
          );
        case BasicHabitSubtype.evaluation:
          return (evalutationComputing, evalutationComputingFormatted);
        case BasicHabitSubtype.completion:
          return (completionComputing, completionComputingFormatted);
        case BasicHabitSubtype.habitsValidated:
          return (
            totalHabitCompletedComputing,
            totalHabitCompletedComputingFormatted
          );
        case BasicHabitSubtype.bsumStreaks:
          return (sumStreaksComputing, sumStreaksComputingFormatted);
      }
      break;

    case StatType.habit:
      switch (stat.formulaType) {
        case HabitVisualisationType.rating:
          return (evalutationComputing, evalutationComputingFormatted);
        case HabitVisualisationType.percentCompletion:
          return (completionComputing, completionComputingFormatted);
        case HabitVisualisationType.numberValidated:
          return (
            totalHabitCompletedComputing,
            totalHabitCompletedComputingFormatted
          );
        case HabitVisualisationType.sumStreaks:
          return (sumStreaksComputing, sumStreaksComputingFormatted);
      }
      break;
    case StatType.additionalMetrics:
      switch (stat.formulaType) {
        case AdditionalMetricsSubType.average:
          return (edditionalMetricsAverage, additionalMetricsAverageFormatted);
        case AdditionalMetricsSubType.sum:
          return (additionalMetricsSum, addtionalMetricsSumFormatted);
      }
      break;
    case StatType.emotion:
      return (emotionAverage, emotionAverageFormatted);
    default:
      return (() => null, () => null);
  }
  return (() => null, () => null); // Default return to handle any missing cases
}
