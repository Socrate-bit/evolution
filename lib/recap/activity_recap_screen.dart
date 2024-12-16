import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/global/display/big_text_form_field_widget.dart';
import 'package:tracker_v1/recap/display/custom_slider_widget.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';

class HabitRecapScreen extends ConsumerStatefulWidget {
  const HabitRecapScreen(this.habit, this.date,
      {super.key, this.oldTrackedDay, required this.validated});

  final Habit habit;
  final DateTime date;
  final HabitRecap? oldTrackedDay;
  final Validated validated;

  @override
  ConsumerState<HabitRecapScreen> createState() => _HabitRecapScreenState();
}

class _HabitRecapScreenState extends ConsumerState<HabitRecapScreen> {
  final formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;

  double _showUpRating = 0;
  double _investmentRating = 0;
  double _resultRating = 0;
  bool _extra = false;
  bool _goal = false;
  String? _enteredRecap;
  String? _enteredImprovement;
  List<String>? _additionalMetrics;
  Map<String, dynamic>? _additionalInputs;

  // Prepare slider data for dynamic generation
  final List<Map<String, String>> sliderData = [
    {'title': 'Practice quantity', 'tooltip': 'Rate how well you showed up.'},
    {'title': 'Practice quality', 'tooltip': 'Rate your level of investment.'},
    {'title': 'Result obtained', 'tooltip': 'Rate the result of your effort.'},
  ];

  List<double> values = [];

  @override
  void initState() {
    super.initState();

    if (widget.oldTrackedDay != null &&
        widget.oldTrackedDay!.notation != null) {
      _showUpRating = widget.oldTrackedDay!.notation!.quantity!;
      _investmentRating = widget.oldTrackedDay!.notation!.quality;
      _resultRating = widget.oldTrackedDay!.notation!.result;
      _extra = widget.oldTrackedDay!.notation!.dailyGoal == 1 ? true : false;
      _goal = widget.oldTrackedDay!.notation!.weeklyFocus == 1 ? true : false;
      _enteredRecap = widget.oldTrackedDay!.recap;
      _enteredImprovement = widget.oldTrackedDay!.improvements;
      _additionalInputs = widget.oldTrackedDay!.additionalMetrics;
    }

    if (widget.oldTrackedDay != null &&
        widget.oldTrackedDay!.notation == null) {
      _enteredRecap = widget.oldTrackedDay!.recap;
      _additionalInputs = widget.oldTrackedDay!.additionalMetrics;
    }

    values = [
      _showUpRating,
      _investmentRating,
      _resultRating,
    ];
    _additionalMetrics = widget.habit.additionalMetrics;
    if (_additionalMetrics != null && _additionalMetrics!.isNotEmpty) {
      _additionalInputs = _additionalInputs ?? {};
      for (String item in _additionalMetrics!) {
        _additionalInputs![item] = _additionalInputs?[item];
      }
    }
  }

  void submit({Validated? validated}) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();

    HabitRecap newTrackedDay = HabitRecap(
      trackedDayId: widget.oldTrackedDay?.trackedDayId,
      userId: FirebaseAuth.instance.currentUser!.uid,
      habitId: widget.habit.habitId,
      date: widget.oldTrackedDay?.date ?? widget.date,
      done: validated ?? widget.validated,
      notation: Rating(
        quantity: values[0],
        quality: values[1],
        result: values[2],
        weeklyFocus: _goal ? 1 : 0,
        dailyGoal: _extra ? 1 : 0,
      ),
      additionalMetrics: _additionalInputs,
      recap: _enteredRecap,
      improvements: _enteredImprovement,
      dateOnValidation: widget.oldTrackedDay?.dateOnValidation ?? today,
    );

    if (widget.oldTrackedDay == null) {
      ref.read(trackedDayProvider.notifier).addTrackedDay(newTrackedDay);
    } else {
      ref.read(trackedDayProvider.notifier).updateTrackedDay(newTrackedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Column(
      children: [
        const CustomToolTipTitle(
          title: 'Rate your activity',
          content: 'Rate your daily activities',
        ),
        // Generate sliders dynamically
        ...sliderData.asMap().entries.map((entry) {
          int index = entry.key;
          var sliderInfo = entry.value;

          return CustomSlider(
            initialValue: values[index],
            onChanged: (value) {
              values[index] = value;
            },
            toolTipTitle: sliderInfo['title']!,
            tooltipContent: sliderInfo['tooltip']!,
          );
        }),

        const SizedBox(height: 32),
        ListTile(
          subtitle: widget.habit.newHabit == null ||
                  widget.habit.newHabit!.trim().isEmpty
              ? null
              : Text(
                  widget.habit.newHabit!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(),
                ),
          title: Text('Did you reach your weekly focus?',
              style: Theme.of(context).textTheme.titleSmall!),
          trailing: Checkbox(
            value: _goal,
            onChanged: (value) {
              setState(() {
                _goal = value!;
              });
            },
          ),
        ),
        // Extra checkbox field
        ListTile(
          title: Text('Did you reach your daily goal?',
              style: Theme.of(context).textTheme.titleSmall!),
          trailing: Checkbox(
            value: _extra,
            onChanged: (value) {
              setState(() {
                _extra = value!;
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

        const SizedBox(height: 32),
        // Recap and Improvements fields
        BigTextFormField(
          controlledValue: _enteredRecap ?? '',
          onSaved: (value) {
            _enteredRecap = value;
          },
          toolTipTitle: 'How did it go?',
          tooltipContent: 'Provide a recap of your activity',
        ),

        const SizedBox(height: 16),

        BigTextFormField(
          controlledValue: _enteredImprovement ?? '',
          onSaved: (value) {
            _enteredImprovement = value;
          },
          toolTipTitle: 'How can you improve?',
          tooltipContent: 'Suggest improvements for tomorrow',
        ),

        const SizedBox(height: 32),

        // Submit Button
        CustomElevatedButton(submit: () {
          _isSubmitted = true;
          submit();
          Navigator.of(context).pop();
        }),
      ],
    );

    return CustomModalBottomSheet(
      title: 'Activity Evaluation',
      content: PopScope(
          onPopInvokedWithResult: (dipop, result) {
            if (!_isSubmitted &&
                (widget.oldTrackedDay == null ||
                    widget.oldTrackedDay!.done == Validated.notYet)) {
              submit(validated: Validated.notYet);
            }
          },
          child: content),
      formKey: formKey,
    );
  }
}
