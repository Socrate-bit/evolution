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
import 'package:tracker_v1/models/habit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewHabitScreen extends ConsumerStatefulWidget {
  const NewHabitScreen({super.key});

  @override
  ConsumerState<NewHabitScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<NewHabitScreen> {
  final formKey = GlobalKey<FormState>();

  IconData _enteredIcon = Icons.self_improvement;
  String? _enteredName;
  String? _enteredDescription;
  int? _enteredFrequency;
  final List<WeekDay> _enteredWeekdays = [];
  ValidationType _enteredValidationType = ValidationType.binary;
  DateTime today = DateTime.now();
  DateTime? _enteredStartDate;
  DateTime? _enteredEndDate;
  final List<String> _enteredAdditionalMetrics = [];

  void submit() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();

    if (_enteredWeekdays.isEmpty) {
      _enteredWeekdays.addAll([...WeekDay.values]);
      _enteredFrequency = 7;
    } else {
      _enteredFrequency = _enteredWeekdays.length;
    }

    Habit newHabit = Habit(
        userId: FirebaseAuth.instance.currentUser!.uid,
        icon: _enteredIcon,
        name: _enteredName!,
        description: _enteredDescription,
        frequency: _enteredFrequency!,
        weekdays: _enteredWeekdays,
        validationType: _enteredName == 'Daily recap'
            ? ValidationType.recapDay
            : _enteredValidationType,
        startDate:
            _enteredStartDate ?? DateTime(today.year, today.month, today.day),
        endDate: _enteredEndDate,
        additionalMetrics: _enteredAdditionalMetrics);

    Navigator.of(context).pop();
    ref.read(habitProvider.notifier).addHabit(newHabit);
  }

  @override
  Widget build(BuildContext context) {
    return CustomModalBottomSheet(
      title: 'New Habit',
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
          DatePickerWidget(passStartDate: (value) {
            _enteredStartDate = value;
          }, passEndDate: (value) {
            _enteredEndDate = value;
          }),
          const SizedBox(height: 64),
          CustomElevatedButton(
            submit: submit,
            text: 'Create',
          )
        ],
      ),
    );
  }
}
