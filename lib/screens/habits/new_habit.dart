import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icons_launcher/cli_commands.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/utilities/first_where_or_null.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/widgets/new_habit/additional_metrics.dart';
import 'package:tracker_v1/widgets/new_habit/date_picker.dart';
import 'package:tracker_v1/widgets/new_habit/frequency_picker.dart';
import 'package:tracker_v1/widgets/new_habit/icon_picker.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_v1/widgets/recaps/big_text_form_field.dart';
import 'package:tracker_v1/widgets/recaps/custom_tool_tip_title.dart';

class NewHabitScreen extends ConsumerStatefulWidget {
  const NewHabitScreen({this.habit, super.key});

  final Habit? habit;

  @override
  ConsumerState<NewHabitScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<NewHabitScreen> {
  final formKey = GlobalKey<FormState>();

  IconData _enteredIcon = Icons.self_improvement;
  String? _enteredName;
  String? _enteredDescription;
  String? _mainImprovement;
  int _enteredFrequency = 7;
  List<WeekDay> _enteredWeekdays = [];
  HabitType _enteredValidationType = HabitType.simple;
  DateTime now = DateTime.now();
  DateTime? _enteredStartDate;
  DateTime? _enteredEndDate;
  TimeOfDay? _enteredTimeOfTheDay;
  List<String> _enteredAdditionalMetrics = [];
  int _enteredPonderation = 3;
  Color _color = Colors.grey;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _enteredIcon = widget.habit!.icon;
      _enteredName = widget.habit!.name;
      _enteredDescription = widget.habit!.description;
      _mainImprovement = widget.habit!.newHabit;
      _enteredFrequency = widget.habit!.frequency;
      _enteredWeekdays = List.from(widget.habit!.weekdays);
      _enteredValidationType = widget.habit!.validationType;
      _enteredStartDate = widget.habit!.startDate;
      _enteredEndDate = widget.habit!.endDate;
      _enteredTimeOfTheDay = widget.habit!.timeOfTheDay;
      _enteredPonderation = widget.habit!.ponderation;
      _color = widget.habit!.color;
      _enteredAdditionalMetrics = List.from(widget.habit!.additionalMetrics!);
    }
  }

  void submit() {
    DateTime today = DateTime(now.year, now.month, now.day);

    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();

    if (_enteredWeekdays.isEmpty) {
      _enteredWeekdays.addAll([...WeekDay.values]);
    } else {
      _enteredFrequency = _enteredWeekdays.length;
    }

    Habit newHabit = Habit(
        userId: FirebaseAuth.instance.currentUser!.uid,
        habitId: widget.habit?.habitId,
        icon: _enteredIcon,
        name: _enteredName!,
        description: _enteredDescription,
        newHabit: _mainImprovement,
        frequency: _enteredFrequency,
        weekdays: _enteredWeekdays,
        validationType: _enteredName == 'Daily recap'
            ? HabitType.recapDay
            : _enteredValidationType,
        startDate: _enteredStartDate ?? today,
        endDate: _enteredEndDate,
        timeOfTheDay: _enteredTimeOfTheDay,
        additionalMetrics: _enteredAdditionalMetrics,
        orderIndex: widget.habit?.orderIndex ?? ref.read(habitProvider).length,
        ponderation: _enteredPonderation,
        color: _color,
        frequencyChanges: widget.habit != null
            ? Map<DateTime, int>.from(widget.habit!.frequencyChanges)
            : {today: _enteredFrequency});

    if (widget.habit != null && widget.habit!.frequency != _enteredFrequency) {
      newHabit.frequencyChanges.addAll({today: _enteredFrequency});
    }

    if (widget.habit != null) {
      ref.read(habitProvider.notifier).updateHabit(widget.habit!, newHabit);
    } else {
      ref.read(habitProvider.notifier).addHabit(newHabit);
    }

    Navigator.of(context).pop();
  }

  void showColorPicker() {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            backgroundColor: Colors.black,
            content: BlockPicker(
                pickerColor: _color,
                onColorChanged: (value) {
                  setState(() {
                    _color = value;
                  });
                })));
  }

  @override
  Widget build(BuildContext context) {
    List<HabitType> habitTypeList = List.from(HabitType.values);
    if (ref.read(habitProvider).firstWhereOrNull(
                (h) => h.validationType == HabitType.recapDay) !=
            null &&
        widget.habit != null &&
        widget.habit!.validationType != HabitType.recapDay) {
      habitTypeList.remove(HabitType.recapDay);
    }

    return CustomModalBottomSheet(
      title: widget.habit != null ? 'Edit Habit' : 'New Habit',
      formKey: formKey,
      content: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconPickerWidget(
                passIcon: (pickedIcon) {
                  _enteredIcon = pickedIcon;
                },
                defaultIcon: _enteredIcon,
              ),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BigTextFormField(
                    maxLenght: 100,
                    maxLine: 1,
                    controlledValue: _enteredName ?? '',
                    onSaved: (value) {
                      _enteredName = value;
                    },
                    toolTipTitle: 'Name',
                    tooltipContent: 'Provide a name of this habit',
                  ),
                ],
              ))
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const CustomToolTipTitle(
                  title: 'Color:', content: 'Select the color of the stat'),
              Spacer(),
              Center(
                child: InkWell(
                  onTap: showColorPicker,
                  child: CircleAvatar(
                    backgroundColor: _color,
                    radius: 24,
                  ),
                ),
              ),
              Spacer(),
            ],
          ),
          const SizedBox(height: 16),
          BigTextFormField(
            controlledValue: _enteredDescription ?? '',
            onSaved: (value) {
              _enteredDescription = value;
            },
            toolTipTitle: 'Description',
            tooltipContent: 'Provide a description of this habit',
          ),
          Row(
            children: [
              const CustomToolTipTitle(
                  title: 'Priority:', content: 'Importance'),
              Expanded(
                child: Center(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(5)),
                      child: DropdownButton(
                        value: _enteredPonderation,
                        icon: const Icon(Icons.arrow_drop_down),
                        isDense: true,
                        dropdownColor:
                            Theme.of(context).colorScheme.surfaceBright,
                        items: Ponderation.values.reversed
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.index + 1,
                                child: Text(item.name.toString().capitalize()),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _enteredPonderation = value;
                          });
                        },
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          FrequencyPicker(
            passFrequency: (value) {
              _enteredFrequency = value;
            },
            enteredWeekdays: _enteredWeekdays,
          ),
          const SizedBox(height: 16),
          Row(children: [
            const CustomToolTipTitle(
                title: 'Time of the day:', content: 'Time'),
            Expanded(
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    _enteredTimeOfTheDay = await showTimePicker(
                        context: context,
                        initialTime:
                            widget.habit?.timeOfTheDay ?? TimeOfDay.now(),
                        initialEntryMode: TimePickerEntryMode.input);
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceBright),
                  child: Text(
                    _enteredTimeOfTheDay == null
                        ? 'Whenever'
                        : _enteredTimeOfTheDay!.format(context),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            )
          ]),
          const SizedBox(height: 16),
          Row(
            children: [
              const CustomToolTipTitle(
                  title: 'Habit type:', content: 'Item type'),
              Expanded(
                child: Center(
                  child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceBright,
                          borderRadius: BorderRadius.circular(5)),
                      child: DropdownButton(
                        value: _enteredValidationType,
                        icon: const Icon(Icons.arrow_drop_down),
                        isDense: true,
                        dropdownColor:
                            Theme.of(context).colorScheme.surfaceBright,
                        items: habitTypeList
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(habitTypeDescriptions[item] ?? ''),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _enteredValidationType = value;
                          });
                        },
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          if (_enteredValidationType == HabitType.recap ||
              _enteredValidationType == HabitType.recapDay)
            BigTextFormField(
              maxLenght: 100,
              maxLine: 1,
              controlledValue: _mainImprovement ?? '',
              onSaved: (value) {
                _mainImprovement = value;
              },
              toolTipTitle: 'Weekly focus',
              tooltipContent: 'Main improvement',
            ),
          const SizedBox(height: 32),
          AdditionalMetrics(_enteredAdditionalMetrics),
          if (_enteredValidationType == HabitType.recap)
            const SizedBox(height: 32),
          DatePickerWidget(
            passStartDate: (value) {
              _enteredStartDate = value;
            },
            passEndDate: (value) {
              _enteredEndDate = value;
            },
            startDate: _enteredStartDate,
            endDate: _enteredEndDate,
            unique: _enteredValidationType == HabitType.unique,
          ),
          const SizedBox(height: 64),
          CustomElevatedButton(
            submit: submit,
            text: widget.habit != null ? 'Edit' : 'Create',
          )
        ],
      ),
    );
  }
}
