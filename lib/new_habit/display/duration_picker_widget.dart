import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:tracker_v1/global/display/toggle_button_widget.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';
import 'package:tracker_v1/new_habit/display/frequency_picker2_widget.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';
import 'package:tracker_v1/notifications/display/notification_widget.dart.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

const List<Duration> preMadeDuration = [
  Duration(minutes: 1),
  Duration(minutes: 5),
  Duration(minutes: 30),
  Duration(hours: 1),
  Duration(hours: 2)
];

class DurationPickerWidget extends StatelessWidget {
  const DurationPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 35,
          child: Row(
            children: [
              CustomToolTipTitle(title: 'Duration:', content: ''),
              Spacer(),
              _CustomDurationButton(),
            ],
          ),
        ),
        SizedBox(height: 12),
        _DurationToggle()
      ],
    );
  }
}

class _CustomDurationButton extends ConsumerWidget {
  const _CustomDurationButton();

  void _addNotification(context, WidgetRef ref) {
    Duration actualDuration = ref.read(newHabitStateProvider).duration;

    picker.DatePicker.showPicker(
      context,
      theme: picker.DatePickerTheme(
        containerHeight: 150,
        backgroundColor: Theme.of(context).colorScheme.surfaceBright,
        itemStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        cancelStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
        doneStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
      showTitleActions: true,
      pickerModel: CustomPicker(
          currentTime: DateTime(0, 0, 0, actualDuration.inHours,
              actualDuration.inMinutes.remainder(60))),
      onConfirm: (date) {
        ref
            .read(newHabitStateProvider.notifier)
            .setDuration(Duration(hours: date.hour, minutes: date.minute));
      },
    );
  }

  String durationFormatter(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}min';
    } else {
      return '${duration.inMinutes}min';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newHabitStateProvider);

    return TextButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        _addNotification(context, ref);
      },
      child: Text(
          preMadeDuration.indexWhere((d) =>
                      d.inMicroseconds ==
                      ref
                          .read(newHabitStateProvider)
                          .duration
                          .inMicroseconds) ==
                  -1
              ? 'Custom'
              : 'More...',
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: ref.read(newHabitStateProvider).color)),
    );
  }
}

class _DurationToggle extends ConsumerWidget {
  const _DurationToggle({super.key});
  static const List<String> pageNames = [
    '1 min',
    '5 min',
    '30 min',
    '1 hour',
    '2 hours'
  ];

  int selectClosest(Duration duration) {
    List<int> shift = preMadeDuration
        .map((e) => (e.inSeconds - duration.inSeconds).abs())
        .toList();
    return shift.indexOf(shift.min);
  }

  String? getSelectedText(Duration duration) {
    bool contain = preMadeDuration
            .indexWhere((d) => d.inMicroseconds == duration.inMicroseconds) ==
        -1;
    return !contain ? null : durationFormatter(duration);
  }

  String durationFormatter(Duration duration) {
    if (duration.inHours > 0 && duration.inMinutes.remainder(60) > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h';
    } else {
      return '${duration.inMinutes}min';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Habit state = ref.read(newHabitStateProvider);

    return CustomContainerTight(
      child: CustomToggleButton(
          color: state.color,
          fillLower: true,
          pageNames: pageNames,
          selectedTest: getSelectedText(state.duration),
          selected: selectClosest(state.duration),
          onPressed: (index) {
            ref
                .read(newHabitStateProvider.notifier)
                .setDuration(preMadeDuration[index]);
          }),
    );
  }
}
