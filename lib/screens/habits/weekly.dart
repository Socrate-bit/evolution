import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/widgets/weekly/additional_metrics_table.dart';
import 'package:tracker_v1/widgets/weekly/emotions_table.dart';
import 'package:tracker_v1/widgets/weekly/shift_week.dart';
import 'package:tracker_v1/widgets/weekly/weekly_table.dart';

class WeeklyScreen extends ConsumerStatefulWidget {
  const WeeklyScreen({super.key});

  @override
  ConsumerState<WeeklyScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<WeeklyScreen> {
  static final _dateFormatter = DateFormat.Md();
  int weekIndex = 0;
  int pageIndex = 0;
  List<String> pageNames = ['Habits', 'Metrics', 'Emotions'];
 

  List<DateTime> get _getOffsetWeekDays {
    DateTime now = DateTime.now();
    int weekShift = weekIndex * 7;
    return List.generate(
        7,
        (i) => DateTime(
            now.year, now.month, now.day - now.weekday + 1 + i + weekShift));
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> offsetWeekDays = _getOffsetWeekDays;
    Widget content;
    switch (pageIndex) {
      case 0:
        content = WeeklyTable(offsetWeekDays: offsetWeekDays);
        break;
      case 1:
        content = AdditionalMetricsTable(offsetWeekDays: offsetWeekDays);
      default:
        content = EmotionTable(offsetWeekDays: offsetWeekDays);
        break;
    }

    return Column(
      children: [
        WeekShifter(
          dateFormatter: _dateFormatter,
          offsetWeekDays: offsetWeekDays,
          updateWeekIndex: (value) {
            setState(() {
              weekIndex += value;
            });
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                ToggleButtons(
                    constraints: const BoxConstraints(
                      minHeight: 20, // Minimum height for the buttons
                      minWidth: 64, // Minimum width for the buttons
                    ),
                    isSelected: List.generate(3, (index) => index == pageIndex),
                    fillColor: Colors.grey.withOpacity(0.5),
                    onPressed: (index) {
                      setState(() {
                        pageIndex = index;
                      });
                    },
                    children: List.generate(3, (index) {
                      return Container(
                        width: 72,
                        height: 20,
                        alignment: Alignment.center,
                        child: Text(
                          pageNames[index],
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      );
                    })),
                content,
                const SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
