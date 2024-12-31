import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/global/display/custom_surface_container.dart';
import 'package:tracker_v1/new_habit/display/frequency_picker2_widget.dart';
import 'package:tracker_v1/weekly/display/additional_metrics_table_widget.dart';
import 'package:tracker_v1/weekly/display/emotions_table_widget.dart';
import 'package:tracker_v1/weekly/display/week_shifter_widget.dart';
import 'package:tracker_v1/weekly/display/weekly_table_widget.dart';

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
    final List<Widget> pages = [
      WeeklyTable(offsetWeekDays: offsetWeekDays),
      AdditionalMetricsTable(offsetWeekDays: offsetWeekDays),
      EmotionTable(offsetWeekDays: offsetWeekDays),
    ];

    return Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
        child: Column(children: [
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
            onTap: (value) => HapticFeedback.selectionClick(),
          ),
          Expanded(
              child: TabBarView(controller: tabController, children: [
            ...pages.map(
              (table) => SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  decoration: BoxDecoration(
    
                      borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 16.0),
                  child: table,
                ),
              ),
            )
          ]))
        ]));
  }
}
