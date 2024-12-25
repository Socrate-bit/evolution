import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';
import 'package:tracker_v1/global/logic/capitalize_string.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/new_habit/data/frequency_state.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/display/frequency_picker2_widget.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';

class TimeOfTheDayField extends ConsumerWidget {
  const TimeOfTheDayField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(
        children: [
          const CustomToolTipTitle(title: 'Time of the day:', content: 'Time'),
          Spacer(),
          if ((frequencyState.type == FrequencyType.Weekly ||
                  (frequencyState.type == FrequencyType.Daily && frequencyState.period1 == 1)) &&
              frequencyState.daysOfTheWeek != null && !frequencyState.whenever &&
              frequencyState.daysOfTheWeek!.isNotEmpty &&
              frequencyState.daysOfTheWeek!.length > 1)
            TextButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (ctx) => _MultipleTimePicker());
                },
                child: Text('More...',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        color: ref.read(newHabitStateProvider).color))),
        ],
      ),
      _CustomTimePicker(
        mainPicker: true,
      ),
    ]);
  }
}

class _CustomTimePicker extends ConsumerStatefulWidget {
  const _CustomTimePicker({super.key, this.mixedSpecificDay, this.mainPicker});
  final WeekDay? mixedSpecificDay;
  final bool? mainPicker;

  @override
  ConsumerState<_CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends ConsumerState<_CustomTimePicker> {
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final FocusNode _hourFocusNode = FocusNode();
  final FocusNode _minuteFocusNode = FocusNode();

  late TimeOfDay? initialTime;

  @override
  void initState() {
    _hourFocusNode.addListener(() {
      _onTimeChanged(day: widget.mixedSpecificDay);
      setState(() {});
    });
    _minuteFocusNode.addListener(() {
      _onTimeChanged(day: widget.mixedSpecificDay);
      setState(() {});
    });
    super.initState();
  }

  void initStateWidget() {
    List<WeekDay>? daysOfTheWeek =
        ref.read(frequencyStateProvider).daysOfTheWeek;

    // Init the initial time
    int index = widget.mixedSpecificDay != null
        ? DaysOfTheWeekUtility.weekDayToNumber[widget.mixedSpecificDay]! - 1
        : daysOfTheWeek != null && daysOfTheWeek.isNotEmpty
            ? DaysOfTheWeekUtility.weekDayToNumber[daysOfTheWeek.first]! - 1
            : 0;

    initialTime = ref.read(frequencyStateProvider).timesOfTheDay?[index];

    // Set the intial time value
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hourController.text =
          initialTime?.hour.toString().padLeft(2, '0') ?? 'HH';
      _minuteController.text =
          initialTime?.minute.toString().padLeft(2, '0') ?? 'MM';
    });
  }

  @override
  void dispose() {
    _hourFocusNode.dispose();
    _minuteFocusNode.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _onTimeChanged({WeekDay? day}) {
    TimeOfDay? newTime;

    // If empty, set to null
    if (_hourController.text.isEmpty || _minuteController.text.isEmpty) {
      newTime = null;
    } else {
      // If not empty, compute the new time
      int? hour = int.tryParse(_hourController.text);
      int? minute = int.tryParse(_minuteController.text);

      if (hour == null && minute == null) return;

      newTime = TimeOfDay(hour: hour ?? 12, minute: minute ?? 0);
    }

    // If unchanged, return
    if (newTime == initialTime) return;

    // Difference between one picker and mixed
    if (day != null) {
      ref
          .read(frequencyStateProvider.notifier)
          .setTimesOfTheSpecificDay(day, newTime);
    } else {
      ref.read(frequencyStateProvider.notifier).setTimesOfTheDay(newTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    initStateWidget();
    Schedule schedule = ref.read(frequencyStateProvider);
    Color focusedColor = ref.read(newHabitStateProvider).color;

    return Center(
        child: CustomContainerTight(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CustomTimePickerContainer(
                  onTimeChanged: _onTimeChanged,
                  day: widget.mixedSpecificDay,
                  controller: _hourController,
                  hint: 'HH',
                  focusNode: _hourFocusNode),
              SizedBox(
                  width: 40,
                  height: 100,
                  child: Stack(alignment: Alignment.center, children: [
                    Positioned(
                        top: 4,
                        child: Text(':',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 55)))
                  ])),
              _CustomTimePickerContainer(
                  onTimeChanged: _onTimeChanged,
                  day: widget.mixedSpecificDay,
                  controller: _minuteController,
                  hint: 'MM',
                  focusNode: _minuteFocusNode),
            ],
          ),
          if (schedule.isMixedhour() && widget.mainPicker == true)
            Text('! Mixed times !',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: focusedColor)),
          SizedBox(height: 6),
        ],
      ),
    ));
  }
}

class _CustomTimePickerContainer extends ConsumerWidget {
  const _CustomTimePickerContainer({
    super.key,
    required this.controller,
    required this.hint,
    required this.focusNode,
    required this.onTimeChanged,
    this.day,
  });

  final TextEditingController controller;
  final String hint;
  final FocusNode focusNode;
  final WeekDay? day;
  final Function onTimeChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color focusedColor = ref.read(newHabitStateProvider).color;
    Color unfocusedColor = Theme.of(context).colorScheme.surface;

    return Container(
      width: 110,
      height: 75,
      child: TextFormField(
        style: TextStyle(fontSize: 45),
        focusNode: focusNode,
        controller: controller,
        cursorColor: Colors.black,
        cursorHeight: 50,
        keyboardType: TextInputType.number,
        maxLength: 2,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          isDense: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: focusNode.hasFocus ? focusedColor : unfocusedColor,
          focusColor: Theme.of(context).colorScheme.primary,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              )),
          hintText: hint,
          counterText: '',
        ),
        onEditingComplete: () {
          onTimeChanged(ref, day: day);
        },
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MultipleTimePicker extends ConsumerWidget {
  const _MultipleTimePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Schedule frequencyState = ref.read(frequencyStateProvider);

    return CustomModalBottomSheet(
        title: 'Mixed Time',
        content: ListView(shrinkWrap: true, children: [
          ...frequencyState.daysOfTheWeek!.map((day) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(day.name.toString().capitalizeString(),
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white.withOpacity(0.75))),
                  _CustomTimePicker(mixedSpecificDay: day, key: ValueKey(day)),
                  SizedBox(height: 16),
                ],
              ))
        ]));
  }
}
