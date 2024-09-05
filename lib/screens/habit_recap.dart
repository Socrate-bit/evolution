import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/tracked_day.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

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

  @override
  void initState() {
    super.initState();
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

  final Map<double, String> _ratingText = {
    0: 'Awful',
    1.25: "Poor",
    2.5: "Okay",
    3.75: "Perfect",
    5: "Outstanding"
  };

  Color? getRatingColorMap(value) {
    if (_methodRating == 5.0 &&
        _resultRating == 5.0 &&
        _investmentRating == 5.0 &&
        _showUpRating == 5.0) {
      return Colors.purple;
    }
    if (value < 1) return Colors.red;
    if (value < 1.25) return Colors.orange;
    if (value < 2.5) return Theme.of(context).colorScheme.primary;
    if (value < 3.75) return Colors.green;
    if (value == 5) return Colors.purple;
    if (value >= 3.75) return Colors.blue;
    return null;
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
          extra: _extra ? 1 : 0),
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
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Activity Evaluation',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  IconButton(
                    iconSize: 30,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const ToolTipTittle("Rating", "Message1"),
              Text('Show-up',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).iconTheme.color)),
              const SizedBox(
                width: 10,
              ),
              Slider(
                label: _ratingText[_showUpRating],
                activeColor: getRatingColorMap(_showUpRating),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _showUpRating,
                onChanged: (value) {
                  setState(() {
                    _showUpRating = value;
                  });
                },
                min: 0,
                max: 5,
                divisions: 4,
              ),
              Text('Investment',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).iconTheme.color)),
              const SizedBox(
                width: 10,
              ),
              Slider(
                label: _ratingText[_investmentRating],
                activeColor: getRatingColorMap(_investmentRating),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _investmentRating,
                onChanged: (value) {
                  setState(() {
                    _investmentRating = value;
                  });
                },
                min: 0,
                max: 5,
                divisions: 4,
              ),
              Text('Method',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).iconTheme.color)),
              const SizedBox(
                width: 10,
              ),
              Slider(
                label: _ratingText[_methodRating],
                activeColor: getRatingColorMap(_methodRating),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _methodRating,
                onChanged: (value) {
                  setState(() {
                    _methodRating = value;
                  });
                },
                min: 0,
                max: 5,
                divisions: 4,
              ),
              Text('Result',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).iconTheme.color)),
              const SizedBox(
                width: 10,
              ),
              Slider(
                label: _ratingText[_resultRating],
                activeColor: getRatingColorMap(_resultRating),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _resultRating,
                onChanged: (value) {
                  setState(() {
                    _resultRating = value;
                  });
                },
                min: 0,
                max: 5,
                divisions: 4,
              ),
              Row(
                children: [
                  Text('Extra',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Theme.of(context).iconTheme.color)),
                  const SizedBox(
                    width: 8,
                  ),
                  const SizedBox(width: 16),
                  Checkbox(
                      value: _extra,
                      semanticLabel: "Bonjour",
                      onChanged: (value) {
                        setState(() {
                          _extra = value!;
                        });
                      }),
                ],
              ),
              const SizedBox(height: 32),
              const ToolTipTittle("Recap", "Message1"),
              TextFormField(
                initialValue: _enteredRecap,
                minLines: 3,
                maxLines: 3,
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _enteredRecap = value;
                },
                maxLength: 1000,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceBright
                      .withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 8),
              const ToolTipTittle("Improvements", "Message1"),
              TextFormField(
                initialValue: _enteredImprovement,
                minLines: 3,
                maxLines: 3,
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _enteredImprovement = value;
                },
                maxLength: 1000,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceBright
                      .withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary),
                    child: Text(
                      'Submit',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ToolTipTittle extends StatelessWidget {
  const ToolTipTittle(this._title, this._message, {super.key});

  final String _title;
  final String _message;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(_title,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.white)),
      const SizedBox(
        width: 8,
      ),
      Tooltip(
          waitDuration: const Duration(milliseconds: 1),
          message: _message,
          child: Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
            size: 20,
          ))
    ]);
  }
}
