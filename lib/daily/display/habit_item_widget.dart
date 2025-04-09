import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/authentification/data/userdata_model.dart';
import 'package:tracker_v1/authentification/data/userdata_provider.dart';
import 'package:tracker_v1/daily/data/daily_screen_state.dart';
import 'package:tracker_v1/global/data/page_enum.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/display/actions_dialog.dart';
import 'package:tracker_v1/global/display/delete_habit_dialog.dart';
import 'package:tracker_v1/global/display/modify_habit_dialog.dart';
import 'package:tracker_v1/global/logic/capitalize_string.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/new_habit/new_habit_screen.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/recap/logic/haptic_validation_logic.dart';
import 'package:tracker_v1/statistics/logic/score_computing_service.dart';
import 'package:tracker_v1/habit/data/habit_status_appearance.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/habit/habit_screen.dart';
import 'package:tracker_v1/recap/simple_recap_screen.dart';
import 'package:tracker_v1/recap/daily_recap_screen.dart';
import 'package:tracker_v1/recap/habit_recap_screen.dart';
import 'package:tracker_v1/theme.dart';

class HabitWidget extends ConsumerStatefulWidget {
  const HabitWidget(
      {required this.habit,
      this.date,
      this.isLastItem = false,
      this.timeMarker,
      this.habitList = false,
      this.habitListNavigation,
      super.key});

  final Habit habit;
  final bool isLastItem;
  final double? timeMarker;
  final DateTime? date;
  final bool habitList;
  final HabitListNavigation? habitListNavigation;

  @override
  ConsumerState<HabitWidget> createState() => _HabitWidgetState();
}

class _HabitWidgetState extends ConsumerState<HabitWidget> {
  HabitRecap? trackedDay;
  bool? pastCurrentTime;
  int? currentStreak;
  TimeOfDay? displayedTime;
  late HabitStatusAppearance appearance;

  @override
  Widget build(BuildContext context) {
    ref.watch(habitProvider);
    _initVariables(ref, context);

    return Dismissible(
        direction: !widget.habitList
            ? DismissDirection.horizontal
            : DismissDirection.none,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            HapticFeedback.lightImpact();
            _startToEndSwiping(widget.habit, ref, context);
          } else if (direction == DismissDirection.endToStart) {
            HapticFeedback.lightImpact();
            _endToStartSwiping(trackedDay, widget.habit, ref, context);
          }
          return false;
        },
        key: ObjectKey(widget.habit),
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        secondaryBackground: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.red,
          ),
        ),
        child: GestureDetector(
            onTap: _onTap,
            child: Row(
              children: [
                _HabitTimeFrame(
                    time: displayedTime,
                    isLastItem: widget.isLastItem,
                    timeMarker: widget.timeMarker,
                    pastCurrentTime: pastCurrentTime,
                    appearance: appearance),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: _HabitMainContainer(
                    habit: widget.habit,
                    appearance: appearance,
                    currentStreak: currentStreak,
                  ),
                ),
              ],
            )));
  }

  List<(ModalContainerItem, bool)> _getAddingDialogItems() {
    DateTime selectedDate = ref.read(dailyScreenStateProvider).selectedDate;

    return [
      (
        ModalContainerItem(
          icon: Icons.edit_rounded,
          title: 'Edit',
          onTap: (context) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => HabitScreen(widget.habit, dateOpened: null),
              ),
            );
          },
        ),
        false
      ),
      (
        ModalContainerItem(
          icon: Icons.add_rounded,
          title: 'Add This Day',
          onTap: (context) {
            Schedule? oldSchedule =
                ref.read(scheduleCacheProvider(null))[widget.habit]?.$1;

            Schedule newSchedule = oldSchedule?.copyWith(
                    active: true,
                    daysOfTheWeek: [
                      DaysOfTheWeekUtility
                          .numberToWeekDay[selectedDate.weekday]!
                    ],
                    startDate: selectedDate,
                    endDate: selectedDate) ??
                Schedule(
                    habitId: widget.habit.habitId,
                    daysOfTheWeek: [
                      DaysOfTheWeekUtility
                          .numberToWeekDay[selectedDate.weekday]!
                    ],
                    startDate: selectedDate,
                    endDate: selectedDate);
            newSchedule.endDate = newSchedule.startDate;
            newSchedule.resetScheduleId();

            ref.read(scheduledProvider.notifier).modifyTodayOnly(newSchedule);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
        ref.read(scheduleCacheProvider(selectedDate)).containsKey(widget.habit),
      ),
      (
        ModalContainerItem(
            icon: Icons.repeat_rounded,
            title: 'Create Routine',
            onTap: (context) {
              showModalBottomSheet(
                  useSafeArea: true,
                  isScrollControlled: true,
                  context: context,
                  builder: (ctx) => NewHabitScreen(
                        habit: widget.habit,
                        navigation: widget.habitListNavigation,
                      ));
            }),
        false
      ),
    ];
  }

  List<(ModalContainerItem, bool)> _getDailyScreenDialogItems() {
    DateTime selectedDate = ref.read(dailyScreenStateProvider).selectedDate;
    (Schedule?, HabitRecap?)? cachedHabit =
        ref.read(scheduleCacheProvider(widget.date))[widget.habit];
    HabitRecap? trackedDay = cachedHabit?.$2;

    return [
      (
        ModalContainerItem(
          icon: Icons.edit_rounded,
          title: 'Edit',
          onTap: (context) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) =>
                    HabitScreen(widget.habit, dateOpened: widget.date),
              ),
            );
          },
        ),
        false
      ),
      (
        ModalContainerItem(
            icon: Icons.check_circle_rounded,
            title: trackedDay == null || trackedDay.done != Validated.yes
                ? (trackedDay?.done != Validated.no ? 'Complete' : 'Reset')
                : 'View Entry',
            onTap: (context) {
              Navigator.of(context).pop();
              _startToEndSwiping(widget.habit, ref, context);
            }),
        false,
      ),
      (
        ModalContainerItem(
          icon: Icons.close_rounded,
          title: trackedDay == null || trackedDay.done != Validated.no
              ? (trackedDay?.done != Validated.yes ? 'Uncomplete' : 'Reset')
              : 'View Entry',
          onTap: (context) {
            Navigator.of(context).pop();
            _endToStartSwiping(trackedDay, widget.habit, ref, context);
          },
        ),
        false
      ),
      (
        ModalContainerItem(
            icon: Icons.delete_rounded,
            title: 'Delete',
            onTap: (context) {
              Schedule? defaultSchedule =
                  ref.read(scheduleCacheProvider(null))[widget.habit]!.$1;
              if (defaultSchedule?.type == FrequencyType.Once) {
                ref
                    .read(scheduledProvider.notifier)
                    .deleteHabitSchedules(cachedHabit!.$1!.habitId!);
                popUntilDailyScreen(context);
              } else {
                showDeleteHabitDialog(context, ref, cachedHabit!.$1!);
              }
            }),
        false
      ),
    ];
  }

  void _onTap() {
    if (widget.habitListNavigation == HabitListNavigation.addHabit) {
      showActionsDialog(context, _getAddingDialogItems(),
          title: widget.habit.name);
    } else if (widget.habitListNavigation == HabitListNavigation.dailyScreen) {
      showActionsDialog(context, _getDailyScreenDialogItems(),
          title: widget.habit.name);
    } else if (widget.habitListNavigation == HabitListNavigation.shareHabit) {
      showModalBottomSheet(
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          builder: (ctx) => NewHabitScreen(
                habit: widget.habit,
                navigation: widget.habitListNavigation,
              ));
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => HabitScreen(widget.habit, dateOpened: widget.date),
        ),
      );
    }
  }

  void _startToEndSwiping(Habit habit, WidgetRef ref, context) {
    (Schedule?, HabitRecap?)? cachedHabit =
        ref.read(scheduleCacheProvider(widget.date))[widget.habit];
    HabitRecap? oldTrackedDay = cachedHabit?.$2;

    Validated getValidationType() {
      return trackedDay?.done == Validated.no
          ? Validated.notYet
          : Validated.yes;
    }

    if (oldTrackedDay?.done == Validated.no) {
      _removeValidation(trackedDay!);
      return;
    }

    _showHabitRecapScreen(
        habit: habit,
        oldTrackedDay: oldTrackedDay,
        getValidationType: getValidationType);

    // Avoid triggering confetti again if already full
    ref.read(dailyScreenStateProvider.notifier).updatePreviousRatio();
  }

  void _endToStartSwiping(
      HabitRecap? trackedDay, Habit habit, WidgetRef ref, context) {
    (Schedule?, HabitRecap?)? cachedHabit =
        ref.read(scheduleCacheProvider(widget.date))[widget.habit];
    HabitRecap? oldTrackedDay = cachedHabit?.$2;

    Validated getValidationType() {
      return trackedDay?.done == Validated.yes
          ? Validated.notYet
          : Validated.no;
    }

    if (oldTrackedDay?.done == Validated.yes) {
      _removeValidation(trackedDay!);
      return;
    }

    _showHabitRecapScreen(
        habit: habit,
        oldTrackedDay: oldTrackedDay,
        getValidationType: getValidationType);

    // Avoid triggering confetti again if already full
    ref.read(dailyScreenStateProvider.notifier).updatePreviousRatio();
  }

  void _showHabitRecapScreen(
      {required Habit habit,
      required HabitRecap? oldTrackedDay,
      required Function getValidationType}) {
    void showModalBottomSheetCustom({required Widget screen}) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => screen,
      );
    }

    switch (habit.validationType) {
      case HabitType.recap:
        showModalBottomSheetCustom(
            screen: HabitRecapScreen(habit, widget.date!,
                oldTrackedDay: oldTrackedDay, validated: getValidationType()));

      case HabitType.recapDay:
        DailyRecap? oldRecapDay =
            ref.read(dailyRecapProvider).firstWhereOrNull((td) {
          return td.date == widget.date;
        });
        showModalBottomSheetCustom(
            screen: DailyRecapScreen(widget.date!, habit,
                oldDailyRecap: oldRecapDay,
                oldTrackedDay: oldTrackedDay,
                validated: getValidationType()));

      default:
        HabitRecap? oldTrackedDay =
            ref.read(scheduleCacheProvider(widget.date))[habit]?.$2;

        showModalBottomSheetCustom(
            screen: BasicRecapScreen(
          habit,
          widget.date!,
          oldTrackedDay: oldTrackedDay,
          validated: getValidationType(),
        ));
    }
  }

  void _removeValidation(HabitRecap oldTrackedDay) {
    HabitRecap newHabitRecap = oldTrackedDay.copyWith(done: Validated.notYet);
    ref.read(habitRecapProvider.notifier).updateTrackedDay(newHabitRecap);
    validationHaptic(newHabitRecap, oldTrackedDay);
  }

  void _initVariables(WidgetRef ref, context) {
    Schedule? schedule =
        ref.watch(scheduleCacheProvider(widget.date))[widget.habit]?.$1;

    if (!widget.habitList) {
      // Compute current streak
      List<HabitRecap> trackedDays = ref.watch(habitRecapProvider);
      trackedDay =
          ref.read(scheduleCacheProvider(widget.date))[widget.habit]?.$2;

      currentStreak = getCurrentStreak(widget.date ?? today, widget.habit, ref);

      // Compute displayed time
      displayedTime = schedule?.timesOfTheDay?[widget.date!.weekday - 1];
      pastCurrentTime = _isPastCurrentTime(displayedTime);
    } else {
      displayedTime = schedule?.timesOfTheDay?[0];
    }

    appearance =
        _getStatusAppearance(trackedDay, pastCurrentTime, context, ref);
  }

  bool _isPastCurrentTime(TimeOfDay? time) {
    return time == null
        ? DateTime(
              widget.date!.year,
              widget.date!.month,
              widget.date!.day,
            ).compareTo(DateTime.now()) <=
            0
        : DateTime(widget.date!.year, widget.date!.month, widget.date!.day,
                    time.hour, time.minute)
                .compareTo(DateTime.now()) <=
            0;
  }

  HabitStatusAppearance _getStatusAppearance(
      HabitRecap? trackedDay, bool? pastCurrentTime, context, ref) {
    if (widget.habitListNavigation == HabitListNavigation.dailyScreen) {
      return trackedDay != null && trackedDay.done != Validated.notYet
          ? trackedDay.getStatusAppearance(Theme.of(context).colorScheme)
          : HabitStatusAppearance(
              backgroundColor: widget.habit.color.value ==
                      Color.fromARGB(255, 52, 52, 52).value
                  ? const Color.fromARGB(255, 52, 52, 52)
                  : widget.habit.color.withOpacity(0.1),
              elementsColor: pastCurrentTime != null && pastCurrentTime!
                  ? Colors.white
                  : Colors.white.withOpacity(0.45),
            );
    } else {
      return HabitStatusAppearance(
          backgroundColor:
              widget.habit.color.value == Color.fromARGB(255, 52, 52, 52).value
                  ? const Color.fromARGB(255, 52, 52, 52)
                  : widget.habit.color.withOpacity(0.1),
          elementsColor: Colors.white,
          icon: _getIconInHabitList(widget.habit));
    }
  }

  Widget? _getIconInHabitList(Habit habit) {
    if (widget.habitListNavigation == HabitListNavigation.addHabit ||
        ref.read(scheduleCacheProvider(null))[habit]?.$1?.startDate == null) {
      return Icon(
        Icons.add_rounded,
        size: 30,
      );
    } else if (ref.read(habitProvider.notifier).isHabitCurrentlyPaused(habit)) {
      return const Icon(Icons.pause_circle_outline_outlined);
    } else {
      return null;
    }
  }
}

class _HabitTimeFrame extends StatelessWidget {
  const _HabitTimeFrame({
    this.time,
    required this.isLastItem,
    required this.timeMarker,
    required this.pastCurrentTime,
    required this.appearance,
  });

  final TimeOfDay? time;
  final bool isLastItem;
  final double? timeMarker;
  final bool? pastCurrentTime;
  final HabitStatusAppearance? appearance;

  @override
  Widget build(BuildContext context) {
    return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Vertical line
          if (!isLastItem)
            Positioned(
                top: 40,
                child: Container(
                  color: pastCurrentTime != null && pastCurrentTime!
                      ? Colors.white
                      : Colors.white.withOpacity(0.45),
                  width: 2,
                  height: 24,
                )),

          // Time marker
          if (timeMarker != null)
            Positioned(
                top: 34 + 24 - (24 * (1 - timeMarker!)),
                child: Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  height: 8,
                  width: 8,
                )),

          // Time of the day
          Container(
            alignment: Alignment.center,
            height: 48,
            width: 50,
            child: time != null
                ? Text(
                    '${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        color: pastCurrentTime != null && pastCurrentTime!
                            ? Colors.white
                            : Colors.white.withOpacity(0.45),
                        decorationThickness: 2.5,
                        decorationColor: appearance!.elementsColor,
                        fontSize: 16),
                  )
                : Icon(
                    appearance?.lineThrough != null
                        ? Icons.circle
                        : Icons.circle_outlined,
                    size: 25,
                    color: pastCurrentTime != null && pastCurrentTime!
                        ? Colors.white
                        : Colors.white.withOpacity(0.45)),
          ),
        ]);
  }
}

class _HabitMainContainer extends ConsumerWidget {
  final Habit habit;
  final HabitStatusAppearance appearance;
  final int? currentStreak;

  const _HabitMainContainer({
    required this.habit,
    required this.appearance,
    required this.currentStreak,
  });

  Widget decoratedContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      height: 48,
      decoration: BoxDecoration(
          boxShadow: appearance.icon != null ? [basicShadow] : null,
          shape: BoxShape.rectangle,
          color: appearance.backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserData? userData = ref.watch(userDataProvider);

    Widget habitName = Text(
      habit.name.capitalizeString(),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          color: appearance.elementsColor,
          decoration: appearance.lineThrough,
          decorationThickness: 2.5,
          decorationColor: appearance.elementsColor,
          fontSize: 16),
    );

    return decoratedContainer(
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(habit.icon, color: appearance.elementsColor),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
            width: 200,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                if (userData != null && userData.priorityDisplay)
                  Positioned(
                      left: 2,
                      top: 22,
                      child: _PriorityDisplay(
                        priority: habit.ponderation,
                        appearance: appearance,
                      )),
                habitName,
              ],
            )),
        const Spacer(),
        if (appearance.icon != null)
          SizedBox(
              height: 30,
              child: _HabitStatusDisplay(
                currentStreak: currentStreak,
                appearance: appearance,
              )),
      ]),
    );
  }
}

class _HabitStatusDisplay extends StatelessWidget {
  final int? currentStreak;
  final HabitStatusAppearance appearance;

  const _HabitStatusDisplay({
    required this.currentStreak,
    required this.appearance,
  });

  Widget _displayCurrentStreak(int? currentStreak) {
    if (currentStreak == null || currentStreak == 0) {
      return const SizedBox();
    }

    int numberOfIcon = _getNumberOfStreakIcon(currentStreak);

    Widget content = Row(
      children: [
        ...List.generate(
            numberOfIcon,
            (value) => Image.asset(
                  'assets/images/streaks.png',
                  height: 12,
                  width: 12,
                )),
        Text(
          currentStreak.toString(),
          style: const TextStyle(
              fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w900),
        ),
      ],
    );
    return content;
  }

  int _getNumberOfStreakIcon(int streak) {
    if (streak < 1) {
      return 0;
    } else if (streak < 5) {
      return 1;
    } else if (streak < 10) {
      return 2;
    } else if (streak < 25) {
      return 3;
    } else if (streak < 50) {
      return 4;
    } else if (streak < 100) {
      return 5;
    } else if (streak < 200) {
      return 6;
    } else {
      return 7;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        if (currentStreak != null)
          Positioned(
            top: -6,
            right: 18,
            child: _displayCurrentStreak(currentStreak),
          ),
        appearance.icon!,
      ],
    );
  }
}

class _PriorityDisplay extends StatelessWidget {
  final int priority;
  final HabitStatusAppearance appearance;

  const _PriorityDisplay({required this.priority, required this.appearance});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
            5,
            (value) => Row(
                  children: [
                    CircleAvatar(
                      radius: 2.75,
                      backgroundColor: appearance.elementsColor.withOpacity(
                          priority > value
                              ? appearance.elementsColor.a *
                                  (appearance.icon != null ? 1 : 0.7)
                              : appearance.elementsColor.a * 0.2),
                    ),
                    SizedBox(width: 4)
                  ],
                ))
      ],
    );
  }
}
