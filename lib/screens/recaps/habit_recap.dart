import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/tracked_day.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/widgets/recaps/big_text_form_field.dart';
import 'package:tracker_v1/widgets/recaps/custom_slider.dart';
import 'package:tracker_v1/widgets/recaps/custom_tool_tip_title.dart';

class HabitRecapScreen extends ConsumerStatefulWidget {
  const HabitRecapScreen(this.habitId, this.date,
      {super.key, this.oldTrackedDay});

  final String habitId;
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
  double _methodRating = 0;
  bool _extra = false;
  String? _enteredRecap;
  String? _enteredImprovement;

  // Prepare slider data for dynamic generation
  final List<Map<String, String>> sliderData = [
    {'title': 'Show-up', 'tooltip': 'Rate how well you showed up.'},
    {'title': 'Investment', 'tooltip': 'Rate your level of investment.'},
    {'title': 'Method', 'tooltip': 'Rate your method efficiency.'},
    {'title': 'Result', 'tooltip': 'Rate the result of your effort.'},
  ];

  List<double> values = [];

  @override
  void initState() {
    super.initState();
    values = [
      _showUpRating,
      _investmentRating,
      _methodRating,
      _resultRating,
    ];

    if (widget.oldTrackedDay != null) {
      _showUpRating = widget.oldTrackedDay!.notation!.showUp!;
      _investmentRating = widget.oldTrackedDay!.notation!.investment;
      _resultRating = widget.oldTrackedDay!.notation!.result;
      _methodRating = widget.oldTrackedDay!.notation!.method;
      _extra = widget.oldTrackedDay!.notation!.extra == 1 ? true : false;
      _enteredRecap = widget.oldTrackedDay!.recap;
      _enteredImprovement = widget.oldTrackedDay!.improvements;
    }
  }

  void submit() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();

    TrackedDay newTrackedDay = TrackedDay(
      habitId: widget.habitId,
      date: widget.date,
      done: Validated.yes,
      notation: Rating(
        showUp: _showUpRating,
        investment: _investmentRating,
        method: _methodRating,
        result: _resultRating,
        extra: _extra ? 1 : 0,
      ),
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

        // Extra checkbox field
        Row(
          children: [
            Text('Extra',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall!),
            const SizedBox(width: 16),
            Checkbox(
              value: _extra,
              onChanged: (value) {
                setState(() {
                  _extra = value!;
                });
              },
            ),
          ],
        ),

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
