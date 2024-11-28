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

class _MainScreenState extends ConsumerState<WeeklyScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  static final _dateFormatter = DateFormat.Md();
  int weekIndex = 0;
  final List<String> _pageNames = ['Habits', 'Tracking', 'Emotions'];

  List<DateTime> get _getOffsetWeekDays {
    DateTime now = DateTime.now();
    int weekShift = weekIndex * 7;
    return List.generate(
        7,
        (i) => DateTime(
            now.year, now.month, now.day - now.weekday + 1 + i + weekShift));
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<DateTime> offsetWeekDays = _getOffsetWeekDays;

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
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
          TabBar(
            tabs: <Widget>[..._pageNames.map((e) => Text(e))],
            controller: tabController,
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: TabBarView(controller: tabController, children: [
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: WeeklyTable(offsetWeekDays: offsetWeekDays),
                    ),
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child:
                          AdditionalMetricsTable(offsetWeekDays: offsetWeekDays),
                    ),
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: EmotionTable(offsetWeekDays: offsetWeekDays),
                    ),
                  ]),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
