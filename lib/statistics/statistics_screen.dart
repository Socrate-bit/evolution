import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:tracker_v1/global/display/custom_surface_container.dart';
import 'package:tracker_v1/global/display/quick_add_habit_dialog.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/statistics/data/statistics_model.dart';
import 'package:tracker_v1/statistics/data/statistics_state.dart';
import 'package:tracker_v1/statistics/display/chart_widget.dart';
import 'package:tracker_v1/statistics/display/new_stats_screen.dart';
import 'package:tracker_v1/statistics/logic/statistics_service.dart';
import 'package:tracker_v1/statistics/data/statistics_provider.dart';
import 'package:tracker_v1/theme.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  final List<String> _pageNames = ['Daily', 'Weekly', 'Monthly'];

  @override
  initState() {
    super.initState();
    tabController =
        TabController(length: _pageNames.length, vsync: this, initialIndex: 1);
    tabController.addListener(() {
      ref
          .read(statisticsStateProvider.notifier)
          .updateSelectedPeriod(tabController.index);
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(statisticsStateProvider.notifier).resetState();
    // });
  }

  @override
  void dispose() {
    // Remove the listener
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statisticsState = ref.watch(statisticsStateProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        children: [
          TabBar(
            onTap: (value) => HapticFeedback.selectionClick(),
            tabs: const <Widget>[
              Text('Daily'),
              Text('Weekly'),
              Text('Monthly')
            ],
            controller: tabController,
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(children: [
                SizedBox(
                  height: 16,
                ),
                CustomContainer(
                  title: 'Chart',
                  child: LineChartDisplay(
                    statisticsState.allStats.isNotEmpty
                        ? getGraphData(
                            ref,
                            statisticsState
                                .allStats[statisticsState.selectedStat],
                            statisticsState.pickedStartDate,
                            statisticsState.pickedEndDate,
                            statisticsState.offset,
                            statisticsState.selectedPeriod)
                        : null,
                    statisticsState.allStats.isNotEmpty
                        ? statisticsState
                            .allStats[statisticsState.selectedStat].maxY
                        : null,
                    data2: statisticsState.selectedStat2 != null
                        ? getGraphData(
                            ref,
                            statisticsState
                                .allStats[statisticsState.selectedStat2!],
                            statisticsState.pickedStartDate,
                            statisticsState.pickedEndDate,
                            statisticsState.offset,
                            statisticsState.selectedPeriod)
                        : null,
                    pageName: _pageNames[statisticsState.selectedPeriod],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                CustomContainer(
                  title: 'Statistics',
                  child: Column(
                    children: [
                      _DateShift(),
                      _StatsGrid(),
                      SizedBox(
                        height: 12,
                      )
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends ConsumerStatefulWidget {
  const _StatsGrid({super.key});

  @override
  ConsumerState<_StatsGrid> createState() => _StatsGridState();
}

class _StatsGridState extends ConsumerState<_StatsGrid> {
  void showNewStatScreen({Stat? stat}) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => NewStatScreen(
              stat: stat,
            ));
  }

  void deleteStat(Stat stat, bool isMainSelected, bool isSecondarySelected) {
    if (isMainSelected) {
      ref.read(statisticsStateProvider.notifier).updateSelectedStat(0);
    }

    if (isSecondarySelected) {
      ref.read(statisticsStateProvider.notifier).updateSelectedStat2(null);
    }
    ref.read(statNotiferProvider.notifier).deleteStat(stat);
  }

  List<ModalContainerItem> getNewHabitItems(
      WidgetRef ref, int index, StatisticsState screenState, Stat stat) {
    bool isMainSelected = screenState.selectedStat == index;
    bool isSecondarySelected = screenState.selectedStat2 == index;

    void mainSelection() {
      ref.read(statisticsStateProvider.notifier).updateSelectedStat(index);
      if (isSecondarySelected) {
        ref.read(statisticsStateProvider.notifier).updateSelectedStat2(null);
      }
    }

    void secondarySelection() {
      ref.read(statisticsStateProvider.notifier).updateSelectedStat2(index);
      if (isMainSelected) {
        ref.read(statisticsStateProvider.notifier).updateSelectedStat(0);
      }
    }

    return [
      if (!isMainSelected)
        ModalContainerItem(
          icon: Icons.show_chart_rounded,
          title: 'Select',
          onTap: (context) {
            mainSelection();
          },
        ),
      if (!isMainSelected && !isSecondarySelected)
        ModalContainerItem(
          icon: Icons.auto_graph_rounded,
          title: 'Compare',
          onTap: (context) {
            secondarySelection();
          },
        ),
      ModalContainerItem(
        icon: Icons.delete_outline_rounded,
        title: 'Delete',
        onTap: (context) {
          deleteStat(stat, isMainSelected, isMainSelected);
        },
      ),
      ModalContainerItem(
        icon: Icons.edit_rounded,
        title: 'Edit',
        onTap: (context) {
          showNewStatScreen(stat: stat);
        },
      )
    ];
  }

  void selectMain(WidgetRef ref, int index, StatisticsState screenState) {
    if (screenState.selectedStat2 == index) {
      ref.read(statisticsStateProvider.notifier).updateSelectedStat2(null);
    }
    ref.read(statisticsStateProvider.notifier).updateSelectedStat(index);
  }

  void onTap(WidgetRef ref, int index, StatisticsState screenState, Stat stat) {
    showActionsDialog(context, getNewHabitItems(ref, index, screenState, stat),
        title: stat.name);
  }

  void onDoubleTap(WidgetRef ref, int index, StatisticsState screenState) {
    selectMain(ref, index, screenState);
  }

  @override
  Widget build(BuildContext context) {
    StatisticsState screenState = ref.read(statisticsStateProvider);

    dynamic computedStats = getContainerStats(
        ref,
        screenState.allStats,
        screenState.offset,
        screenState.selectedPeriod,
        screenState.pickedStartDate,
        screenState.pickedEndDate);

    return ReorderableGridView.count(
      onDragStart: (dragIndex) => HapticFeedback.lightImpact(),
      dragWidgetBuilder: (index, child) => Material(
          borderRadius: BorderRadius.circular(20),
          borderOnForeground: true,
          type: MaterialType.card,
          child: Container(margin: EdgeInsets.all(2), child: child)),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1,
      onReorder: (oldIndex, newIndex) {
        ref.read(statNotiferProvider.notifier).reorderStats(oldIndex, newIndex);
      },
      footer: [
        InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (ctx) => NewStatScreen());
            },
            child: _AddStatContainer(title: 'Add new stat')),
      ],
      children: [
        ...screenState.allStats.asMap().entries.map((entry) => InkWell(
              key: ObjectKey(entry),
              onDoubleTap: () {
                HapticFeedback.lightImpact();
                onDoubleTap(ref, entry.key, screenState);
              },
              onTap: () {
                HapticFeedback.selectionClick();
                onTap(ref, entry.key, screenState, entry.value);
              },
              child: _StatContainer(
                title: entry.value.name,
                stats: entry.value,
                computedStat: computedStats[entry.key],
                index: entry.key,
              ),
            )),
      ],
    );
  }
}

class _StatContainer extends ConsumerWidget {
  final String title;
  final Stat stats;
  final String computedStat;
  final int index;

  const _StatContainer({
    super.key,
    required this.title,
    required this.stats,
    required this.computedStat,
    required this.index,
  });

  Color getBorderColor(BuildContext context, WidgetRef ref) {
    if (ref.read(statisticsStateProvider).selectedStat == index) {
      return Theme.of(context).colorScheme.secondary;
    } else if (ref.read(statisticsStateProvider).selectedStat2 == index) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [basicShadow],
          border: Border.all(color: getBorderColor(context, ref), width: 3),
          borderRadius: BorderRadius.circular(20),
          color: stats.color,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(computedStat,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          Text(title,
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: stats.color == Theme.of(context).colorScheme.surface
                      ? Colors.grey
                      : Colors.white)),
        ]),
      ),
    );
  }
}

class _AddStatContainer extends StatelessWidget {
  final String title;
  const _AddStatContainer({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
              boxShadow: [basicShadow],
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).colorScheme.surface),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: Radius.circular(20),
            strokeWidth: 3,
            dashPattern: [6, 3],
            color: Colors.grey,
            child: Align(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 30),
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.grey)),
                  ]),
            ),
          )),
    );
  }
}

class _DateShift extends ConsumerWidget {
  const _DateShift({super.key});

  String getDatePickerText(WidgetRef ref, StatisticsState screenState) {
    DateTime? pickedStartDate =
        ref.read(statisticsStateProvider).pickedStartDate;
    DateTime? pickedEndDate = ref.read(statisticsStateProvider).pickedEndDate;

    if (pickedStartDate != null && pickedEndDate != null) {
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      return '${formatter.format(pickedStartDate)} - ${formatter.format(pickedEndDate)}';
    }
    ;

    switch (screenState.selectedPeriod) {
      case 0:
        return screenState.offset == 0
            ? 'This week'
            : '${screenState.offset} weeks ago';
      case 1:
        DateFormat formatter = DateFormat('MMMM yyyy');
        DateTime month = DateTime(today.year, today.month - screenState.offset);
        return screenState.offset == 0 ? 'This month' : formatter.format(month);
      default:
        DateFormat formatter = DateFormat('yyyy');
        DateTime year = DateTime(today.year - screenState.offset, today.month);
        return screenState.offset == 0 ? 'This year' : formatter.format(year);
    }
  }

  Future<void> _showDatePicker(context, WidgetRef ref) async {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Select a date range'),
              content: SizedBox(
                height: 400,
                width: 400,
                child: SfDateRangePicker(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  headerStyle: DateRangePickerHeaderStyle(
                      textStyle: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.normal),
                      backgroundColor: Theme.of(context).colorScheme.surface),
                  toggleDaySelection: true,
                  showNavigationArrow: true,
                  showActionButtons: true,
                  showTodayButton: true,
                  cancelText: 'RESET',
                  onCancel: () {
                    Navigator.of(context).pop();
                    ref.read(statisticsStateProvider.notifier).resetDate();
                  },
                  onSubmit: (pickedDate) {
                    if (pickedDate is PickerDateRange) {
                      ref
                          .read(statisticsStateProvider.notifier)
                          .updatePickedStartDate(pickedDate.startDate!);
                      ref
                          .read(statisticsStateProvider.notifier)
                          .updatePickedEndDate(pickedDate.endDate!);
                      Navigator.of(context).pop();
                    } else {
                      return;
                    }
                  },
                  selectionMode: DateRangePickerSelectionMode.range,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    StatisticsState screenState = ref.read(statisticsStateProvider);

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(statisticsStateProvider.notifier).updateOffset(1);
              },
              icon: const Icon(Icons.arrow_left_rounded, size: 60),
            ),
            InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _showDatePicker(context, ref);
              },
              child: Text(getDatePickerText(ref, screenState),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontSize: 18)),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(statisticsStateProvider.notifier).updateOffset(-1);
              },
              icon: const Icon(
                Icons.arrow_right_rounded,
                size: 60,
              ),
            )
          ]),
    );
  }
}
