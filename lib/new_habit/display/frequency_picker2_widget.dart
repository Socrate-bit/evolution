import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/display/toggle_button_widget.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/new_habit/data/frequency_state.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/display/startend_date_modal.dart';

class FrequencyPickerWidget extends ConsumerStatefulWidget {
  const FrequencyPickerWidget({super.key});

  @override
  ConsumerState<FrequencyPickerWidget> createState() =>
      _FrequencyPickerWidgetState();
}

class _FrequencyPickerWidgetState extends ConsumerState<FrequencyPickerWidget> {
  static const double _interSpace = 12;

  @override
  Widget build(BuildContext context) {
    Schedule frequencyState = ref.watch(frequencyStateProvider);

    return Column(
      children: [
        SizedBox(
          height: 35,
          child: Row(
            children: [
              CustomToolTipTitle(title: 'Frequency:', content: ''),
              Spacer(),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 500),
                child: frequencyState.type != FrequencyType.Once
                    ? _TextDatePicker()
                    : null,
              ),
            ],
          ),
        ),
        _ToggleFrequencyType(),
        SizedBox(height: _interSpace),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 750),
          child: getContent(frequencyState),
        ),
      ],
    );
  }

  Widget getContent(Schedule frequencyState) {
    switch (frequencyState.type) {
      case FrequencyType.Once:
        return _OnceDatePicker();
      case FrequencyType.Daily:
        return _PeriodPicker();
      case FrequencyType.Weekly:
        return Column(
          children: [
            _PeriodPicker(),
            SizedBox(height: _interSpace),
            _ToggleWhenever(),
            SizedBox(height: _interSpace),
            if (frequencyState.whenever) _Period2Picker(),
            if (!frequencyState.whenever) _WeekdayPicker(),
          ],
        );
      case FrequencyType.Monthly:
        return Column(
          children: [
            _PeriodPicker(),
            SizedBox(height: _interSpace),
            _ToggleWhenever(),
            SizedBox(height: _interSpace),
            if (frequencyState.whenever) _Period2Picker(),
            if (!frequencyState.whenever) _MonthDatePicker(),
          ],
        );
    }
  }
}

class _TextDatePicker extends ConsumerWidget {
  const _TextDatePicker();

  String getTextDate(Schedule frequencyState) {
    String date = '';

    if (frequencyState.endingDate == null && frequencyState.startDate != null) {
      date = 'Starting on ${formater3.format(frequencyState.startDate!)}';
    } else if (frequencyState.startDate == null) {
      date = 'No start date';
    } else if (frequencyState.endingDate != null &&
        frequencyState.startDate != null) {
      date =
          '${formater4.format(frequencyState.startDate!)} - ${formater4.format(frequencyState.endingDate!)}';
    }

    return date;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);

    String date = getTextDate(frequencyState);

    return TextButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        showModalBottomSheet(
            context: context, builder: (context) => StartEndDateBottom());
      },
      child: Text(date,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(color: ref.read(newHabitStateProvider).color)),
    );
  }
}

class _ToggleFrequencyType extends ConsumerWidget {
  const _ToggleFrequencyType({super.key});
  static const pageNames = ['Once', 'Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);
    return CustomContainerTight(
      child: CustomToggleButton(
          color: ref.read(newHabitStateProvider).color,
          pageNames: pageNames,
          selected: FrequencyType.values.indexOf(frequencyState.type!),
          onPressed: (index) {
            ref
                .read(frequencyStateProvider.notifier)
                .setFrequencyType(FrequencyType.values[index]);
          }),
    );
  }
}

class _PeriodPicker extends ConsumerWidget {
  const _PeriodPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);
    String period1 =
        frequencyState.period1 != 1 ? '${frequencyState.period1} ' : '';
    String typeString;

    switch (frequencyState.type) {
      case FrequencyType.Daily:
        typeString = 'days';
        break;
      case FrequencyType.Weekly:
        typeString = 'weeks';
        break;
      case FrequencyType.Monthly:
        typeString = 'months';
        break;
      default:
        typeString = '';
    }

    if (frequencyState.period1 == 1) {
      typeString = typeString.substring(0, typeString.length - 1);
    }

    return CustomContainerTight(
      uniqueKey: UniqueKey(),
      child: Row(
        children: [
          SizedBox(width: 20),
          Text(
            'Every $period1$typeString',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Colors.white),
          ),
          Spacer(),
          _AddSubstractButton(
            onPressed: (int value) {
              if (frequencyState.period1! < 2 && value == -1) {
                return;
              }
              HapticFeedback.lightImpact();
              ref
                  .read(frequencyStateProvider.notifier)
                  .setPeriod1(frequencyState.period1 + value);
            },
          ),
        ],
      ),
    );
  }
}

class _Period2Picker extends ConsumerWidget {
  const _Period2Picker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);
    int period2 = frequencyState.period2;
    String typeString;
    String timeString = period2 > 1 ? 'times' : 'time';

    switch (frequencyState.type) {
      case FrequencyType.Weekly:
        typeString = 'week';
        break;
      case FrequencyType.Monthly:
        typeString = 'month';
        break;
      default:
        typeString = '';
    }

    return CustomContainerTight(
      child: Row(
        children: [
          SizedBox(width: 20),
          Text(
            '$period2 $timeString per $typeString',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Colors.white),
          ),
          Spacer(),
          _AddSubstractButton(
            onPressed: (int value) {
              if (frequencyState.period2! < 2 && value == -1) {
                return;
              }
              HapticFeedback.lightImpact();
              ref
                  .read(frequencyStateProvider.notifier)
                  .setPeriod2(frequencyState.period2 + value);
            },
          ),
        ],
      ),
    );
  }
}

class _AddSubstractButton extends StatelessWidget {
  const _AddSubstractButton({super.key, required this.onPressed});
  final void Function(int) onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
            ),
            onPressed: () {
              onPressed(-1);
            },
          ),
          Container(
            height: 20,
            width: 1,
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withOpacity(0.25),
          ),
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            onPressed: () {
              onPressed(1);
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleWhenever extends ConsumerWidget {
  const _ToggleWhenever({super.key});
  static const pagesNames = ['Planned', 'Random'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);
    return CustomContainerTight(
      child: CustomToggleButton(
          color: ref.read(newHabitStateProvider).color,
          pageNames: pagesNames,
          selected: frequencyState.whenever ? 1 : 0,
          onPressed: (index) {
            ref
                .read(frequencyStateProvider.notifier)
                .setWhenever(index == 0 ? false : true);
          }),
    );
  }
}

class _WeekdayPicker extends ConsumerWidget {
  const _WeekdayPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomContainerTight(
      uniqueKey: UniqueKey(),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ...WeekDay.values.expand(
          (weekDay) {
            return [_CircleToggleDay(weekDay)];
          },
        ),
      ]),
    );
  }
}

class _CircleToggleDay extends ConsumerWidget {
  const _CircleToggleDay(this.weekday, {super.key});

  final WeekDay weekday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);
    List<WeekDay> enteredWeekdays = frequencyState.daysOfTheWeek!;

    return GestureDetector(
      onTap: () {
        if (enteredWeekdays.contains(weekday)) {
          HapticFeedback.selectionClick();
          ref
              .read(frequencyStateProvider.notifier)
              .setDaysOfTheWeek(List.from(enteredWeekdays)..remove(weekday));
        } else {
          HapticFeedback.lightImpact();
          ref
              .read(frequencyStateProvider.notifier)
              .setDaysOfTheWeek(List.from(enteredWeekdays)..add(weekday));
        }
      },
      child: Container(
        alignment: Alignment.center,
        height: 40,
        width: 40,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.25),
                width: 1),
            borderRadius: BorderRadius.circular(8),
            color: enteredWeekdays.contains(weekday)
                ? ref.read(newHabitStateProvider).color
                : Theme.of(context).colorScheme.surfaceBright),
        child: Text(
          DaysOfTheWeekUtility.weekDayToSign[weekday]!,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.white,
              fontWeight:
                  enteredWeekdays.contains(weekday) ? FontWeight.bold : null),
        ),
      ),
    );
  }
}

class CustomContainerTight extends StatelessWidget {
  final Widget? child;
  final Key? uniqueKey;

  const CustomContainerTight({super.key, this.child, this.uniqueKey});

  @override
  Widget build(BuildContext context) {
    return Container(
        key: uniqueKey,
        padding: const EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.surfaceBright),
        child: Column(
          children: [if (child != null) child!],
        ));
  }
}

class _OnceDatePicker extends ConsumerWidget {
  const _OnceDatePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);
    DateTime startDate = frequencyState.startDate ?? today;
    String startDateDisplay = 'On the ${formater1.format(startDate)}';

    if (startDate == today ||
        startDate == today.subtract(Duration(days: 1)) ||
        startDate == today.add(Duration(days: 1))) {
      startDateDisplay = displayedDate(startDate);
    }

    return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _datePicker(context, ref);
        },
        child: CustomContainerTight(
            uniqueKey: UniqueKey(),
            child: Text(startDateDisplay,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.white))));
  }
}

class _MonthDatePicker extends ConsumerWidget {
  const _MonthDatePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);
    String suffix =
        getOrdinalSuffix(frequencyState.startDate?.day ?? today.day);
    String startDate =
        'On every ${formater2.format(frequencyState.startDate ?? today)}$suffix';

    return GestureDetector(
        onTap: () => _datePicker(context, ref),
        child: CustomContainerTight(
            uniqueKey: UniqueKey(),
            child: Text(startDate,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!
                    .copyWith(color: Colors.white))));
  }
}

Future<void> _datePicker(context, WidgetRef ref) async {
  Schedule frequencyState = ref.read(frequencyStateProvider);
  DateTime initial = frequencyState.startDate ?? today;

  DateTime firstDate = DateTime(initial.year - 1, initial.month, initial.day);
  DateTime lastDate = DateTime(initial.year + 1, initial.month, initial.day);

  DateTime? pickedDate = await showDatePicker(
    context: context,
    firstDate: firstDate,
    lastDate: lastDate,
    initialDate: initial,
  );

  if (pickedDate != null) {
    ref.read(frequencyStateProvider.notifier).setStartDate(pickedDate);
  }
}
