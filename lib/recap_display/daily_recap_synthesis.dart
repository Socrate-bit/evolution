import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/daily/display/score_card_widget.dart';
import 'package:tracker_v1/global/display/animations.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/global/logic/offset_days.dart';
import 'package:tracker_v1/habit/data/habit_status_appearance.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/recap/daily_recap_screen.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/recap/habit_recap_screen.dart';
import 'package:tracker_v1/recap/simple_recap_screen.dart';
import 'package:tracker_v1/recap_display/synthesis_state.dart';
import 'package:tracker_v1/statistics/logic/score_computing_service.dart';

class DailySynthesis extends ConsumerStatefulWidget {
  const DailySynthesis(
      {super.key, this.date, this.habit, required this.entries});
  final DateTime? date;
  final Habit? habit;
  final List<MapEntry<Habit, HabitRecap?>> entries;

  @override
  ConsumerState<DailySynthesis> createState() => _DailySynthesisState();
}

class _DailySynthesisState extends ConsumerState<DailySynthesis> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      {
        ref.read(synthesisStateProvider.notifier).setDate(widget.date);
        ref.read(synthesisStateProvider.notifier).setHabit(widget.habit);
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) globalKey.currentState?.save();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            title: Text(widget.date == null
                ? widget.habit!.name
                : formater4.format(widget.date!)),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _TopBarBlock(widget.habit),
              Expanded(
                child: Form(
                  key: globalKey,
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: widget.entries
                        .map((entry) => _HabitItem(entry))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class _TopBarBlock extends ConsumerWidget {
  const _TopBarBlock(this.habit);
  final Habit? habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime? date = ref.watch(synthesisStateProvider).date;

    return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        height: 60,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Spacer(), DailyScore(habit: habit, date: date)],
        ));
  }
}

class DailyScore extends ConsumerWidget {
  const DailyScore({super.key, required this.date, required this.habit});
  final Habit? habit;
  final DateTime? date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<DateTime> offsetDays = [];

    if (date == null) {
      DateTime? startDate = ref
          .read(scheduledProvider.notifier)
          .getHabitStartDate(habit!.habitId);

      if (startDate != null) {
        offsetDays = OffsetDays.getOffsetDays(startDate, now);
      }
    }

    double? score = evalutationComputing(
        date == null ? offsetDays : [date!], ref,
        reference: habit?.habitId);
    String ratio = completionComputingFormatted(
        date == null ? offsetDays : [date!], ref,
        reference: habit?.habitId);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          ratio,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.grey),
        ),
        SizedBox(width: 16),
        ScoreCard(date, score),
      ],
    );
  }
}

class _HabitItem extends StatefulWidget {
  const _HabitItem(this.habitEntry);
  final MapEntry<Habit, HabitRecap?> habitEntry;

  @override
  State<_HabitItem> createState() => _HabitItemState();
}

class _HabitItemState extends State<_HabitItem> {
  late bool showTextField;

  @override
  void initState() {
    // TODO: implement initState
    showTextField = !textFieldsEmpty();
    super.initState();
  }

  bool textFieldsEmpty() {
    return (widget.habitEntry.value?.recap == null ||
            widget.habitEntry.value!.recap!.isEmpty) &&
        (widget.habitEntry.value?.improvements == null ||
            widget.habitEntry.value!.improvements!.isEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                showTextField = !showTextField;
              });
            },
            child: _TitleBlock(widget.habitEntry, showTextField)),
        SwitcherAnimation(showTextField
            ? Column(children: [
                _CustomTextFormField(widget.habitEntry, true),
                _CustomTextFormField(widget.habitEntry, false),
              ])
            : SizedBox()),
        SizedBox(height: 16),
      ],
    );
  }
}

class _TitleBlock extends ConsumerWidget {
  const _TitleBlock(this.habitEntry, this.show);
  final MapEntry<Habit, HabitRecap?> habitEntry;
  final bool show;

  void _onTap(Habit habit, BuildContext context, HabitRecap oldTrackedDay,
      WidgetRef ref) {
    DateTime date = oldTrackedDay.date;

    if (habit.validationType == HabitType.simple) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => BasicRecapScreen(
          habit,
          date,
          oldTrackedDay: oldTrackedDay,
          validated: oldTrackedDay.done,
        ),
      );
    } else if (habit.validationType == HabitType.recap) {
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => HabitRecapScreen(habit, date,
            oldTrackedDay: oldTrackedDay, validated: oldTrackedDay.done),
      );
    } else if (habit.validationType == HabitType.recapDay) {
      RecapDay? oldRecapDay = ref.read(recapDayProvider).firstWhereOrNull((td) {
        return td.date == date;
      });
      showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => DailyRecapScreen(date, habit,
            oldDailyRecap: oldRecapDay,
            oldTrackedDay: oldTrackedDay,
            validated: oldTrackedDay.done),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Expanded(child: _HabitTitle(habitEntry)),
            Icon(show ? Icons.expand_less_rounded : Icons.expand_more_rounded),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  _onTap(habitEntry.key, context, habitEntry.value!, ref);
                },
                child: _AvatarNotation(habitEntry)),
          ],
        ));
  }
}

class _HabitTitle extends ConsumerWidget {
  const _HabitTitle(this.habitEntry);
  final MapEntry<Habit, HabitRecap?> habitEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime? date = ref.watch(synthesisStateProvider).date;
    final DateTime? dateRecapDay = habitEntry.value?.date;
    final habit = habitEntry.key;

    String text = date == null ? formater3.format(dateRecapDay!) : habit.name;

    return Row(
      children: [
        Icon(
          habit.icon,
          size: 30,
          color: habit.color,
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Container(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium!,
            ),
          ),
        )
      ],
    );
  }
}

class _AvatarNotation extends ConsumerWidget {
  const _AvatarNotation(this.habitEntry, {super.key});
  final MapEntry<Habit, HabitRecap?> habitEntry;

  Widget forceOverrideColor(Widget? widget, Color color) {
    if (widget is Icon) {
      return Icon(widget.icon, color: color, size: 35);
    } else if (widget is Text) {
      return Text(widget.data ?? '', style: TextStyle(color: color));
    } else {
      return widget ?? SizedBox();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = habitEntry.value?.totalRating() ?? 0;
    final HabitStatusAppearance? appearance =
        habitEntry.value?.getStatusAppearance(Theme.of(context).colorScheme);
    appearance?.elementsColor = Colors.white;

    // Assuming score is part of HabitRecap
    return CircleAvatar(
        radius: 20,
        backgroundColor: appearance?.backgroundColor ??
            const Color.fromARGB(255, 51, 51, 51),
        child: IconTheme(
          data: IconThemeData(color: Colors.white),
          child:
              forceOverrideColor(appearance?.icon, Colors.white) ?? SizedBox(),
        ));
  }
}

class _CustomTextFormField extends ConsumerStatefulWidget {
  const _CustomTextFormField(this.habitEntry, this.recap);
  final MapEntry<Habit, HabitRecap?> habitEntry;
  final bool recap;

  @override
  ConsumerState<_CustomTextFormField> createState() =>
      _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends ConsumerState<_CustomTextFormField> {
  late TextEditingController controller;
  String? oldText;
  late final HabitRecap? habitRecap;

  @override
  void initState() {
    habitRecap = widget.habitEntry.value;
    oldText = widget.recap ? habitRecap?.recap : habitRecap?.improvements;
    controller = TextEditingController(text: (oldText) ?? '');
    super.initState();
  }

  void uploadOldText() {
    DateTime? date = ref.read(synthesisStateProvider).date;

    if (oldText != controller.text) {
      HabitRecap newRecap = (widget.recap
              ? habitRecap?.copyWith(recap: controller.text)
              : habitRecap?.copyWith(improvements: controller.text)) ??
          HabitRecap(
            userId: FirebaseAuth.instance.currentUser!.uid,
            habitId: widget.habitEntry.key.habitId,
            date: date!,
            done: Validated.notYet,
            recap: widget.recap ? controller.text : null,
            improvements: widget.recap ? null : controller.text,
          );

      ref.read(trackedDayProvider.notifier).updateTrackedDay(newRecap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final habit = widget.habitEntry.key;

    return TextFormField(
      textInputAction: TextInputAction.newline,
      onFieldSubmitted: (value) {
        FocusScope.of(context).unfocus();
      },
      onSaved: (newValue) => uploadOldText(),
      maxLines: null,
      controller: controller,
      style: Theme.of(context).textTheme.bodyMedium,
      cursorColor: habit.color,
      decoration: InputDecoration(
        enabledBorder: InputBorder.none,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: habit.color, width: 1),
        ),
      ),
    );
  }
}
