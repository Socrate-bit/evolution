import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/global/display/big_text_form_field_widget.dart';
import 'package:tracker_v1/recap/logic/haptic_validation_logic.dart';

class BasicRecapScreen extends ConsumerStatefulWidget {
  const BasicRecapScreen(this.habit, this.date,
      {super.key, this.oldTrackedDay, required this.validated});


  final Habit habit;
  final DateTime date;
  final HabitRecap? oldTrackedDay;
  final Validated validated;

  @override
  ConsumerState<BasicRecapScreen> createState() => _HabitRecapScreenState();
}

class _HabitRecapScreenState extends ConsumerState<BasicRecapScreen> {
  final formKey = GlobalKey<FormState>();

  String? _enteredRecap;
  List<String>? _additionalMetrics;
  Map<String, dynamic>? _additionalInputs;
  bool _isSubmitted = false;

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
      additionalMetrics: _additionalInputs,
      recap: _enteredRecap,
      dateOnValidation: widget.oldTrackedDay?.dateOnValidation ?? today,
    );

    validationHaptic(newTrackedDay, widget.oldTrackedDay);

    if (widget.oldTrackedDay == null) {
      ref.read(trackedDayProvider.notifier).addTrackedDay(newTrackedDay);
    } else {
      ref.read(trackedDayProvider.notifier).updateTrackedDay(newTrackedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = PopScope(
      onPopInvokedWithResult: (dipop, result) {
        if (!_isSubmitted &&
            (widget.oldTrackedDay == null ||
                widget.oldTrackedDay!.done == Validated.notYet)) {
          submit(validated: Validated.notYet);
        }
      },
      child: Column(
        children: [
          // Recap and Improvements fields
          BigTextFormField(
            minLine: 3,
            maxLine: 20,
            color: widget.habit.color,
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
                title:
                    Text(item, style: Theme.of(context).textTheme.titleSmall!),
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
                          filled: true,
                          counterText: '',
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: widget.habit.color,
                            ),
                          ),
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceBright
                              .withOpacity(0.75),
                        ))),
              );
            }),

          const SizedBox(height: 32),

          // Submit Button
          CustomElevatedButton(
            submit: () async{
              _isSubmitted = true;
              submit(validated: widget.validated);
              Navigator.of(context).pop();

            },
            color: widget.habit.color,
          ),
        ],
      ),
    );

    return CustomModalBottomSheet(
      title: 'Activity Evaluation',
      content: content,
      formKey: formKey,
    );
  }
}
