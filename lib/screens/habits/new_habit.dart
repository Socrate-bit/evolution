import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/widgets/new_habit/additional_metrics.dart';
import 'package:tracker_v1/widgets/new_habit/date_picker.dart';
import 'package:tracker_v1/widgets/new_habit/frequency_picker.dart';
import 'package:tracker_v1/widgets/new_habit/text_form_field.dart';
import 'package:tracker_v1/widgets/new_habit/icon_picker.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  int _enteredFrequency = 7;
  List<WeekDay> _enteredWeekdays = [];
  ValidationType _enteredValidationType = ValidationType.binary;
  DateTime now = DateTime.now();
  DateTime? _enteredStartDate;
  DateTime? _enteredEndDate;
  List<String> _enteredAdditionalMetrics = [];

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _enteredIcon = widget.habit!.icon;
      _enteredName = widget.habit!.name;
      _enteredDescription = widget.habit!.description;
      _enteredFrequency = widget.habit!.frequency;
      _enteredWeekdays = List.from(widget.habit!.weekdays);
      _enteredValidationType = widget.habit!.validationType;
      _enteredStartDate = widget.habit!.startDate;
      _enteredEndDate = widget.habit!.endDate;
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
        id: widget.habit?.id,
        icon: _enteredIcon,
        name: _enteredName!,
        description: _enteredDescription,
        frequency: _enteredFrequency,
        weekdays: _enteredWeekdays,
        validationType: _enteredName == 'Daily recap'
            ? ValidationType.recapDay
            : _enteredValidationType,
        startDate: _enteredStartDate ?? today,
        endDate: _enteredEndDate,
        trackedDays: widget.habit != null
            ? Map.from(widget.habit!.trackedDays)
            : <DateTime, String>{},
        additionalMetrics: _enteredAdditionalMetrics,
        orderIndex: widget.habit?.orderIndex ?? ref.read(habitProvider).length,
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

  @override
  Widget build(BuildContext context) {
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
                  BasicTextFormField(
                    maxLength: 30,
                    label: 'Name',
                    optional: true,
                    wrongEntryMessage: 'Invalid name',
                    passValue: (value) {
                      _enteredName = value;
                    },
                    initialValue: _enteredName,
                  ),
                ],
              ))
            ],
          ),
          const SizedBox(height: 16),
          BasicTextFormField(
            maxLength: 100,
            label: 'Description (Optional)',
            passValue: (value) {
              _enteredDescription = value;
            },
            initialValue: _enteredDescription,
          ),
          const SizedBox(height: 32),
          FrequencyPicker(
            passFrequency: (value) {
              _enteredFrequency = value;
            },
            enteredWeekdays: _enteredWeekdays,
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            subtitle: Text(_enteredValidationType == ValidationType.evaluation
                ? 'Switch to simple habit:'
                : 'Switch to activity:'),
            title: const Text('Habit type'),
            value: _enteredValidationType == ValidationType.evaluation,
            onChanged: (value) {
              setState(
                () {
                  if (value == true) {
                    _enteredValidationType = ValidationType.evaluation;
                  } else {
                    _enteredValidationType = ValidationType.binary;
                  }
                },
              );
            },
          ),
          const SizedBox(height: 32),
          AdditionalMetrics(_enteredAdditionalMetrics),
          const SizedBox(height: 16),
          DatePickerWidget(
            passStartDate: (value) {
              _enteredStartDate = value;
            },
            passEndDate: (value) {
              _enteredEndDate = value;
            },
            startDate: _enteredStartDate,
            endDate: _enteredEndDate,
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
