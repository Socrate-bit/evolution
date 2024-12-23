import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/display/big_text_form_field_widget.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';

class AdditionalMetrics extends ConsumerStatefulWidget {
  const AdditionalMetrics(this.enteredAdditionalMetrics, {super.key});

  final List<String> enteredAdditionalMetrics;

  @override
  ConsumerState<AdditionalMetrics> createState() => _AdditionalMetricsState();
}

class _AdditionalMetricsState extends ConsumerState<AdditionalMetrics> {
  String? _additionalMetrics;
  final formKey = GlobalKey<FormState>();

  void _addAdditionalMetrics(context) {
    FocusScope.of(context).unfocus();
    if (widget.enteredAdditionalMetrics.length > 4) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: const Text('Maximum additional fields reached'),
                backgroundColor: Theme.of(context).colorScheme.surfaceBright,
              ));
      return;
    }
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      formKey.currentState!.save();
      widget.enteredAdditionalMetrics.add(_additionalMetrics!);
      _additionalMetrics = null;
    });
    formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    Habit habitState = ref.watch(newHabitProvider);

    return Form(
      key: formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: BigTextFormField(
                  color: habitState.color,
                  maxLenght: 100,
                  maxLine: 1,
                  controlledValue: _additionalMetrics ?? '',
                  onSaved: (value) {
                    _additionalMetrics = value;
                  },
                  toolTipTitle: 'Additional tracking:',
                  tooltipContent: 'Provide Additional tracking (Optional)',
                ),
              ),
              IconButton(
                  onPressed: () {
                    _addAdditionalMetrics(context);
                  },
                  icon: const Icon(Icons.add))
            ],
          ),
          if (widget.enteredAdditionalMetrics.isNotEmpty)
            SizedBox(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.enteredAdditionalMetrics.length,
                  itemBuilder: (ctx, item) {
                    return Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.enteredAdditionalMetrics[item],
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  widget.enteredAdditionalMetrics.remove(
                                      widget.enteredAdditionalMetrics[item]);
                                });
                              },
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                              ))
                        ],
                      ),
                    );
                  }),
            )
        ],
      ),
    );
  }
}
