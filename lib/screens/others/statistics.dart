import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/utilities/Scores/score_computing.dart';
import 'package:tracker_v1/screens/others/chart.dart';
import 'package:tracker_v1/widgets/global/toggle_button.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  final List<String> _pageNames = ['Rating', '%Ratio', 'Streaks'];
  int _selected = 0;

  List<DateTime> _getOffsetWeekDays(weekIndex) {
    DateTime now = DateTime.now();
    int weekShift = weekIndex * 7;
    return List.generate(
        7,
        (i) => DateTime(
            now.year, now.month, now.day - now.weekday + 1 + i - weekShift));
  }

  List<(DateTime, double?)> getData(ref) {
    int pastShift = 12;
    List<(DateTime, double?)> notation = [];

    for (int shift = 0; shift <= pastShift; shift++) {
      List<DateTime> weekDays =
          _getOffsetWeekDays(shift).where((d) => !d.isAfter(today)).toList();
      if (_selected == 0) {
        notation.add((weekDays.first, notationComputing(weekDays, ref)));
      } else if (_selected == 1) {
        notation.add((weekDays.first, ratioComputing(weekDays, ref)));
      } else {
        notation.add(
            (weekDays.first, sumStreaksComputing(ref, dates: weekDays)?.toDouble()));
      }
    }

    return notation.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface),
        child: Column(
          children: [
            CustomToggleButton(
                pageNames: _pageNames,
                selected: _selected,
                onPressed: (index) {
                  setState(() {
                    _selected = index;
                  });
                }),
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).colorScheme.surfaceBright),
                child: LineChartSample2(getData(ref), _selected))
          ],
        ),
      
    );
  }
}
