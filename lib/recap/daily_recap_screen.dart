import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/effects/effects_service.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/recap/data/daily_recap_model.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/global/display/big_text_form_field_widget.dart';
import 'package:tracker_v1/recap/data/daily_recap_provider.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/recap/display/custom_toggle_widget.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';

class DailyRecapScreen extends ConsumerStatefulWidget {
  const DailyRecapScreen(this.date, this.habit,
      {super.key,
      this.oldDailyRecap,
      this.oldTrackedDay,
      required this.validated});

  final DateTime date;
  final Habit habit;
  final HabitRecap? oldTrackedDay;
  final RecapDay? oldDailyRecap;
  final Validated validated;

  @override
  ConsumerState<DailyRecapScreen> createState() => _HabitRecapScreenState();
}

class _HabitRecapScreenState extends ConsumerState<DailyRecapScreen> {
  final formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;

  List<String>? _additionalMetrics;
  Map<String, dynamic>? _additionalInputs;

  List<double> values = List.filled(11, 2.5); // For storing slider values
  Map<String, String?> textFieldValues = {
    'Recap': null,
    'Improvements': null,
    'Emotions': null,
    'Gratefulness': null,
    'Proudness': null,
    'Help': null,
  };

  // List of slider metadata (titles and tooltip contents)
  final sliderData = [
    {'title': 'Did you feel good?', 'tooltip': 'Rate your well-being'},
    {'title': 'Did you sleep well?', 'tooltip': 'Rate your energy level'},
    {'title': 'Did you have energy?', 'tooltip': 'Rate your energy level'},
    {'title': 'Were you motivated?', 'tooltip': 'Rate your motivation'},
    {'title': 'Were you stressed?', 'tooltip': 'Rate your stress level'},
    {'title': 'Were you focused?', 'tooltip': 'Rate your focus'},
    {
      'title': 'Was your mental performance good?',
      'tooltip': 'Rate your mental power'
    },
    {'title': 'Were you frustrated?', 'tooltip': 'Rate your frustrations'},
    {'title': 'Were you satisfied?', 'tooltip': 'Rate your satisfaction'},
    {
      'title': 'Did you have good self-esteem?',
      'tooltip': 'Rate your self-esteem'
    },
    {
      'title': 'Do you look forward to wake-up tomorrow?',
      'tooltip': 'Rate your eagerness to wake up tomorrow'
    },
  ];

  // List of BigTextField metadata (titles and tooltips)
  final textFieldData1 = [
    {
      'title': 'How was your day?',
      'tooltip': 'Provide a summary of your day',
      'reference': 'Recap'
    },
  ];

  final textFieldData2 = [
    {
      'title': 'How do you feel?',
      'tooltip': 'Write how you feel',
      'reference': 'Emotions'
    },
    {
      'title': 'What can you improve?',
      'tooltip': 'Write what you can improve',
      'reference': 'Improvements'
    },
    {
      'title': 'One thing you are grateful for',
      'tooltip': 'Write what you\'re grateful for',
      'reference': 'Gratefulness'
    },
    {
      'title': 'One thing you are proud of',
      'tooltip': 'Write what you\'re proud of',
      'reference': 'Proudness'
    },
    {
      'title': 'One person you helped today',
      'tooltip': 'Write what good actions you\'ve done',
      'reference': 'Help'
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.oldDailyRecap != null) {
      values[0] = widget.oldDailyRecap!.wellBeing;
      values[1] = widget.oldDailyRecap!.sleepQuality;
      values[2] = widget.oldDailyRecap!.energy;
      values[3] = widget.oldDailyRecap!.driveMotivation;
      values[4] = widget.oldDailyRecap!.stress;
      values[5] = widget.oldDailyRecap!.focusMentalClarity;
      values[6] = widget.oldDailyRecap!.intelligenceMentalPower;
      values[7] = widget.oldDailyRecap!.frustrations;
      values[8] = widget.oldDailyRecap!.satisfaction;
      values[9] = widget.oldDailyRecap!.selfEsteemProudness;
      values[10] = widget.oldDailyRecap!.lookingForwardToWakeUpTomorrow;
      textFieldValues['Recap'] = widget.oldDailyRecap!.recap;
      textFieldValues['Improvements'] = widget.oldDailyRecap!.improvements;
      textFieldValues['Emotions'] = widget.oldDailyRecap!.emotionalRecap;
      textFieldValues['Gratefulness'] = widget.oldDailyRecap!.gratefulness;
      textFieldValues['Proudness'] = widget.oldDailyRecap!.proudness;
      textFieldValues['Help'] = widget.oldDailyRecap!.altruism;
      _additionalInputs = widget.oldDailyRecap!.additionalMetrics;
    }

    _additionalMetrics = widget.habit.additionalMetrics;
    if (_additionalMetrics != null && _additionalMetrics!.isNotEmpty) {
      _additionalInputs = _additionalInputs ?? {};
      for (String item in _additionalMetrics!) {
        _additionalInputs![item] = _additionalInputs?[item];
      }
    }
  }

  void _submit({Validated? validated}) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();

    RecapDay newRecapDay = RecapDay(
        recapId: widget.oldDailyRecap?.recapId,
        userId: FirebaseAuth.instance.currentUser!.uid,
        wellBeing: values[0],
        sleepQuality: values[1],
        energy: values[2],
        driveMotivation: values[3],
        stress: values[4],
        focusMentalClarity: values[5],
        intelligenceMentalPower: values[6],
        frustrations: values[7],
        satisfaction: values[8],
        selfEsteemProudness: values[9],
        lookingForwardToWakeUpTomorrow: values[10],
        date: widget.date,
        recap: textFieldValues['Recap'],
        improvements: textFieldValues['Improvements'],
        emotionalRecap: textFieldValues['Emotions'],
        gratefulness: textFieldValues['Gratefulness'],
        proudness: textFieldValues['Proudness'],
        altruism: textFieldValues['Help'],
        additionalMetrics: _additionalInputs);

    HabitRecap trackedDay = HabitRecap(
      trackedDayId: widget.oldTrackedDay?.trackedDayId,
      userId: FirebaseAuth.instance.currentUser!.uid,
      habitId: widget.habit.habitId,
      date: widget.oldTrackedDay?.date ?? widget.date,
      done: validated ?? widget.validated,
      dateOnValidation: widget.oldTrackedDay?.dateOnValidation ?? today,
    );

    if (trackedDay.done == Validated.yes) {
      EffectsService().playValidated();
      HapticFeedback.heavyImpact();
    } else if (trackedDay.done == Validated.no) {
      EffectsService().playFaillure();
      HapticFeedback.lightImpact();
    }

    if (widget.oldDailyRecap == null) {
      ref.read(recapDayProvider.notifier).addRecapDay(newRecapDay);

      ref.read(trackedDayProvider.notifier).addTrackedDay(trackedDay);
    } else {
      ref.read(recapDayProvider.notifier).updateRecapDay(newRecapDay);
      if (widget.oldTrackedDay != null) {
        ref.read(trackedDayProvider.notifier).updateTrackedDay(trackedDay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(children: [
      ...textFieldData1.map((fieldInfo) {
        return BigTextFormField(
          minLine: 3,
          maxLine: 20,
          color: widget.habit.color,
          controlledValue: textFieldValues[fieldInfo['reference']] ?? '',
          onSaved: (value) {
            textFieldValues[fieldInfo['reference']!] = value;
          },
          toolTipTitle: fieldInfo['title']!,
          tooltipContent: fieldInfo['tooltip']!,
        );
      }),

      if (_additionalMetrics != null && _additionalMetrics!.isNotEmpty)
        ..._additionalMetrics!.map((item) {
          return ListTile(
            title: Text(item, style: Theme.of(context).textTheme.titleSmall!),
            trailing: SizedBox(
                width: 64,
                child: TextFormField(
                    style: Theme.of(context).textTheme.bodyMedium,
                    initialValue: _additionalInputs?[item],
                    onSaved: (newValue) {
                      _additionalInputs![item] = newValue;
                    },
                    cursorColor: widget.habit.color,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: widget.habit.color,
                        ),
                      ),
                      filled: true,
                      counterText: '',
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceBright
                          .withOpacity(0.75),
                    ))),
          );
        }),
      const SizedBox(height: 16),
      const CustomToolTipTitle(
          title: 'How do you feel?', content: 'Emotional checking'),
      // Generate sliders dynamically
      ...sliderData.asMap().entries.map((entry) {
        int index = entry.key;
        var sliderInfo = entry.value;

        return CustomToggleButtonsSlider(
          initialValue: values[index],
          onChanged: (value) {
            values[index] = value;
          },
          toolTipTitle: sliderInfo['title']!,
          tooltipContent: sliderInfo['tooltip']!,
        );
      }),

      const SizedBox(height: 32),

      // Generate BigTextFields dynamically
      ...textFieldData2.map((fieldInfo) {
        return BigTextFormField(
          color: widget.habit.color,
          controlledValue: textFieldValues[fieldInfo['reference']] ?? '',
          onSaved: (value) {
            textFieldValues[fieldInfo['reference']!] = value;
          },
          toolTipTitle: fieldInfo['title']!,
          tooltipContent: fieldInfo['tooltip']!,
          minLine: 2,
          maxLine: 20,
        );
      }),

      const SizedBox(height: 64),

      // Submit Button
      CustomElevatedButton(
        submit: () {
          _isSubmitted = true;
          _submit();
          Navigator.of(context).pop();
        },
        color: widget.habit.color,
      ),
    ]);

    return CustomModalBottomSheet(
        title: 'Journaling & Emotions',
        content: PopScope(
            onPopInvokedWithResult: (dipop, result) {
              if (!_isSubmitted &&
                  (widget.oldTrackedDay == null ||
                      widget.oldTrackedDay!.done == Validated.notYet)) {
                _submit(validated: Validated.notYet);
              }
            },
            child: content),
        formKey: formKey);
  }
}
