import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

  /// Returns a list of `DateTime` objects representing each day of a target week.
  /// The week is calculated based on the `weekIndex` which shifts the current week.
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                WeekShifter(
                    dateFormatter: _dateFormatter,
                    offsetWeekDays: offsetWeekDays,
                    updateWeekIndex: (value) {
                      setState(() {
                        weekIndex += value;
                      });
                    }),
                const SizedBox(
                  height: 8,
                ),
                WeeklyTable(offsetWeekDays: offsetWeekDays)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
