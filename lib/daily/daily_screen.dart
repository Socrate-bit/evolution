import 'dart:collection';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/daily/data/daily_screen_state.dart';
import 'package:tracker_v1/effects/effects_service.dart';
import 'package:tracker_v1/global/data/page_enum.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/daily/display/day_switcher_widget.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/global/display/habits_reorderable_list_widget.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/statistics/logic/score_computing_service.dart';

class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  late ConfettiController confettiController;
  late Widget content;

  @override
  void initState() {
    super.initState();
    confettiController =
        ConfettiController(duration: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  void setConfettiTrigger(DailyScreenState dailyScreenState) {
    ref.listen(
      trackedDayProvider,
      (prev, next) {
        if (completionComputing([dailyScreenState.selectedDate], ref) == 100 &&
            dailyScreenState.previousComputingRatio != 100) {
          HapticFeedback.vibrate();
          EffectsService().playFullValidated();
          confettiController.play();
        }
      },
    );
  }

  Widget setCondionnalContent(DailyScreenState dailyScreenState) {
    final LinkedHashMap<Habit, (Schedule, HabitRecap?)> habitScheduleMap =
        ref.watch(scheduleCacheProvider(dailyScreenState.selectedDate));

    content = habitScheduleMap.isNotEmpty
        ? HabitReorderableList(
            habitScheduleMap: habitScheduleMap,
            selectedDate: dailyScreenState.selectedDate,
            navigation: HabitListNavigation.dailyScreen,)
        : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(
                height: 200,
              ),
              ref.read(habitProvider.notifier).isHabitListEmpty()
                  ? const Text('No habits today 💤')
                  : const Text('No habits yet, create one!')
            ]));

    return content;
  }

  @override
  Widget build(BuildContext context) {
    DailyScreenState dailyScreenState = ref.watch(dailyScreenStateProvider);
    ref.watch(trackedDayProvider);

    setConfettiTrigger(dailyScreenState);
    Widget content = setCondionnalContent(dailyScreenState);

    return Column(
      children: [
        ConfettiWidget(
          blastDirectionality: BlastDirectionality.explosive,
          blastDirection: -pi / 2, 
          emissionFrequency: 1,
          minimumSize: const Size(10, 10),
          maximumSize: const Size(20, 20),
          numberOfParticles: 20,
          maxBlastForce: 200,
          minBlastForce: 10,
          gravity: 0.5,
          confettiController: confettiController,
        ),
        DailyUpperBarWidget(),
        Expanded(child: Center(child: content)),
      ],
    );
  }
}
