import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/datas/habit.dart';
import 'package:tracker_v1/models/datas/tracked_day.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/widgets/recaps/big_text_form_field.dart';

class BasicRecapScreen extends ConsumerStatefulWidget {
  const BasicRecapScreen(this.habit, this.date,
      {super.key, this.oldTrackedDay});

  final Habit habit;
  final DateTime date;
  final TrackedDay? oldTrackedDay;

  @override
  ConsumerState<BasicRecapScreen> createState() => _HabitRecapScreenState();
}

class _HabitRecapScreenState extends ConsumerState<BasicRecapScreen> {
  final formKey = GlobalKey<FormState>();

  String? _enteredRecap;
  List<String>? _additionalMetrics;
  Map<String, dynamic>? _additionalInputs;

  List<double> values = [];

  @override
  void initState() {
    super.initState();

    if (widget.oldTrackedDay != null) {
      _enteredRecap = widget.oldTrackedDay!.recap;
      _additionalInputs = widget.oldTrackedDay!.additionalMetrics;
    }

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
      additionalMetrics: _additionalInputs,
      recap: _enteredRecap,
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
        // Recap and Improvements fields
        BigTextFormField(
          controlledValue: _enteredRecap ?? '',
          onSaved: (value) {
            _enteredRecap = value;
          },
          toolTipTitle: 'Comment',
          tooltipContent: 'Provide a recap of your activity',
        ),
        if (_additionalMetrics != null && _additionalMetrics!.isNotEmpty)
          const SizedBox(height: 32),

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
