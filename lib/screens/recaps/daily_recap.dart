import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/daily_recap.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/widgets/recaps/big_text_form_field.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/widgets/recaps/custom_toggle.dart';
import 'package:tracker_v1/widgets/recaps/custom_tool_tip_title.dart';

class DailyRecapScreen extends ConsumerStatefulWidget {
  const DailyRecapScreen(this.date, this.habit,
      {super.key, this.oldDailyRecap, this.oldTrackedDay});

  final DateTime date;
  final Habit habit;
  final TrackedDay? oldTrackedDay;
  final RecapDay? oldDailyRecap;
  @override
  ConsumerState<DailyRecapScreen> createState() => _HabitRecapScreenState();
}

class _HabitRecapScreenState extends ConsumerState<DailyRecapScreen> {
  final formKey = GlobalKey<FormState>();
  List<String>? _additionalMetrics;
  Map<String, dynamic>? _additionalInputs;

  List<double> values = List.filled(11, 2.5); // For storing slider values
  Map<String, String?> textFieldValues = {
    'Recap': null,
    'Improvements': null,
    'What am I grateful for?': null,
    'What am I proud of?': null,
    'Emotions': null,
  };
  bool _newHabit = false;

  // List of slider metadata (titles and tooltip contents)
  final sliderData = [
    {'title': 'Well-being', 'tooltip': 'Rate your well-being'},
    {'title': 'Sleep', 'tooltip': 'Rate your sleep quality'},
    {'title': 'Energy', 'tooltip': 'Rate your energy level'},
    {'title': 'Motivation', 'tooltip': 'Rate your motivation'},
    {'title': 'Stress', 'tooltip': 'Rate your stress level'},
    {'title': 'Focus & Clarity', 'tooltip': 'Rate your focus'},
    {'title': 'Mental performance', 'tooltip': 'Rate your mental power'},
    {'title': 'Frustrations', 'tooltip': 'Rate your frustrations'},
    {'title': 'Satisfaction', 'tooltip': 'Rate your satisfaction'},
    {'title': 'Self-Esteem', 'tooltip': 'Rate your self-esteem'},
    {
      'title': 'Looking forward to wake-up tomorrow',
      'tooltip': 'Rate your eagerness to wake up tomorrow'
    },
  ];

  // List of BigTextField metadata (titles and tooltips)
  final textFieldData1 = [
    {'title': 'Recap', 'tooltip': 'Provide a summary of your day'},
    {'title': 'Improvements', 'tooltip': 'Provide suggestions for improvement'},
  ];

  final textFieldData2 = [
    {
      'title': 'What am I grateful for?',
      'tooltip': 'Write what you\'re grateful for'
    },
    {'title': 'What am I proud of?', 'tooltip': 'Write what you\'re proud of'},
    {
      'title': 'Who did I help?',
      'tooltip': 'Write what good actions you\'ve done'
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
      _newHabit = widget.oldDailyRecap!.newHabit;
      textFieldValues['Recap'] = widget.oldDailyRecap!.recap;
      textFieldValues['Improvements'] = widget.oldDailyRecap!.improvements;
      textFieldValues['Emotions'] = widget.oldDailyRecap!.emotionalRecap;
      textFieldValues['What am I grateful for?'] =
          widget.oldDailyRecap!.gratefulness;
      textFieldValues['What am I proud of?'] = widget.oldDailyRecap!.proudness;
      textFieldValues['Who did I help?'] = widget.oldDailyRecap!.altruism;
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

  void _submit() {
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
        gratefulness: textFieldValues['What am I grateful for?'],
        proudness: textFieldValues['What am I proud of?'],
        altruism: textFieldValues['Who did I help?'],
        newHabit: _newHabit,
        additionalMetrics: _additionalInputs);

    Navigator.of(context).pop();

    if (widget.oldDailyRecap == null) {
      ref.read(recapDayProvider.notifier).addRecapDay(newRecapDay);
      TrackedDay trackedDay = TrackedDay(
        userId: FirebaseAuth.instance.currentUser!.uid,
        habitId: widget.habit.habitId,
        date: widget.date,
        done: Validated.yes,
      );

      ref.read(trackedDayProvider.notifier).addTrackedDay(trackedDay);
    } else {
      ref.read(recapDayProvider.notifier).updateRecapDay(newRecapDay);
      if (widget.oldTrackedDay != null) {
        ref
            .read(trackedDayProvider.notifier)
            .updateTrackedDay(widget.oldTrackedDay!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(children: [
      ...textFieldData1.map((fieldInfo) {
        return BigTextFormField(
          controlledValue: textFieldValues[fieldInfo['title']] ?? '',
          onSaved: (value) {
            textFieldValues[fieldInfo['title']!] = value;
          },
          toolTipTitle: fieldInfo['title']!,
          tooltipContent: fieldInfo['tooltip']!,
        );
      }),

      ListTile(
        title: Text('Focus of the week',
            style: Theme.of(context).textTheme.titleSmall!),
        trailing: Checkbox(
          value: _newHabit,
          onChanged: (value) {
            setState(() {
              _newHabit = value!;
            });
          },
        ),
      ),

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
                    decoration: InputDecoration(
                      filled: true,
                      counterText: '',
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surfaceBright
                          .withOpacity(0.75),
                    ))),
          );
        }),
      const SizedBox(height: 64),
      const CustomToolTipTitle(
          title: 'Emotional checking', content: 'Emotional checking'),
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

      BigTextFormField(
        controlledValue: textFieldValues['Emotions'] ?? '',
        onSaved: (value) {
          textFieldValues['Emotions'] = value;
        },
        toolTipTitle: 'Emotions',
        tooltipContent: 'Recap your emotions',
        maxLine: 2,
      ),

      // Generate BigTextFields dynamically
      ...textFieldData2.map((fieldInfo) {
        return BigTextFormField(
          controlledValue: textFieldValues[fieldInfo['title']] ?? '',
          onSaved: (value) {
            textFieldValues[fieldInfo['title']!] = value;
          },
          toolTipTitle: fieldInfo['title']!,
          tooltipContent: fieldInfo['tooltip']!,
          maxLine: 1,
        );
      }),

      const SizedBox(height: 64),

      // Submit Button
      CustomElevatedButton(
        submit: _submit,
      ),
    ]);

    return CustomModalBottomSheet(
        title: 'Daily Evaluation', content: content, formKey: formKey);
  }
}
