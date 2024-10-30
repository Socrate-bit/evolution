import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/widgets/recaps/big_text_form_field.dart';
import 'package:tracker_v1/widgets/recaps/custom_slider.dart';
import 'package:tracker_v1/widgets/recaps/custom_tool_tip_title.dart';

class HabitRecapScreen extends ConsumerStatefulWidget {
  const HabitRecapScreen(this.habit, this.date,
      {super.key, this.oldTrackedDay});

  final Habit habit;
  final DateTime date;
  final TrackedDay? oldTrackedDay;

  @override
  ConsumerState<HabitRecapScreen> createState() => _HabitRecapScreenState();
}

class _HabitRecapScreenState extends ConsumerState<HabitRecapScreen> {
  final formKey = GlobalKey<FormState>();

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
    {'title': 'Quantity', 'tooltip': 'Rate how well you showed up.'},
    {'title': 'Quality', 'tooltip': 'Rate your level of investment.'},
    {'title': 'Result', 'tooltip': 'Rate the result of your effort.'},
  ];

  List<double> values = [];

  @override
  void initState() {
    super.initState();

    if (widget.oldTrackedDay != null) {
      _showUpRating = widget.oldTrackedDay!.notation!.quantity!;
      _investmentRating = widget.oldTrackedDay!.notation!.quality;
      _resultRating = widget.oldTrackedDay!.notation!.result;
      _extra = widget.oldTrackedDay!.notation!.dailyGoal == 1 ? true : false;
      _goal = widget.oldTrackedDay!.notation!.weeklyFocus == 1 ? true : false;
      _enteredRecap = widget.oldTrackedDay!.recap;
      _enteredImprovement = widget.oldTrackedDay!.improvements;
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

  void submit() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();

    TrackedDay newTrackedDay = TrackedDay(
      trackedDayId: widget.oldTrackedDay?.trackedDayId,
      userId: FirebaseAuth.instance.currentUser!.uid,
      habitId: widget.habit.habitId,
      date: widget.date,
      done: Validated.yes,
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
    );

    Navigator.of(context).pop();
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
          title: 'Rating',
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

        ListTile(
          subtitle: widget.habit.newHabit == null ||
                  widget.habit.newHabit!.trim().isEmpty
              ? null
              : Text(
                  widget.habit.newHabit!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(),
                ),
          title: Text('Weekly focus',
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
          title: Text('Daily goal', style: Theme.of(context).textTheme.titleSmall!),
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
          toolTipTitle: 'Recap',
          tooltipContent: 'Provide a recap of your activity',
        ),

        const SizedBox(height: 16),

        BigTextFormField(
          controlledValue: _enteredImprovement ?? '',
          onSaved: (value) {
            _enteredImprovement = value;
          },
          toolTipTitle: 'Improvements',
          tooltipContent: 'Suggest improvements for tomorrow',
        ),

        const SizedBox(height: 32),

        // Submit Button
        CustomElevatedButton(submit: submit),
      ],
    );

    return CustomModalBottomSheet(
      title: 'Activity Evaluation',
      content: content,
      formKey: formKey,
    );
  }
}
