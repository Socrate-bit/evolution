import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/statistics_screen/logics/score_computing_service.dart';
import 'package:tracker_v1/widgets/daily/scoreCard.dart';

class WeekShifter extends ConsumerWidget {
  const WeekShifter(
      {required this.dateFormatter,
      required this.offsetWeekDays,
      required this.updateWeekIndex,
      super.key});

  final DateFormat dateFormatter;
  final List<DateTime> offsetWeekDays;
  final void Function(int value) updateWeekIndex;

  _computeWeeklyScore(ref) {
    return evalutationComputing(
        offsetWeekDays.where((e) => !e.isAfter(today)).toList(), ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surface,
      height: 60,
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            width: 300,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      updateWeekIndex(-1);
                    },
                    icon: const Icon(Icons.arrow_left_rounded, size: 60),
                  ),
                  Text(
                      '${dateFormatter.format(offsetWeekDays.first)} - ${dateFormatter.format(offsetWeekDays.last)}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      updateWeekIndex(1);
                    },
                    icon: const Icon(
                      Icons.arrow_right_rounded,
                      size: 60,
                    ),
                  )
                ]),
          ),
          ScoreCard(
            offsetWeekDays[0],
            _computeWeeklyScore(ref),
            weekly: true,
          )
        ],
      ),
    );
  }
}
