import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/daily_recap.dart';
import 'package:tracker_v1/models/tracked_day.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/tracked_day.dart';

class DailyRecapScreen extends ConsumerStatefulWidget {
  const DailyRecapScreen(this.date, this.habitId, {super.key, this.oldTrackedDay});

  final DateTime date;
  final String habitId;
  final RecapDay? oldTrackedDay;

  @override
  ConsumerState<DailyRecapScreen> createState() => _HabitRecapScreenState();
}

class _HabitRecapScreenState extends ConsumerState<DailyRecapScreen> {
  final formKey = GlobalKey<FormState>();

  int _sleepQuality = 0;
  int _wellBeing = 0;
  int _energy = 0;
  int _driveMotivation = 0;
  int _stress = 0;
  int _focusMentalClarity = 0;
  int _intelligenceMentalPower = 0;
  int _frustrations = 0;
  int _satisfaction = 0;
  int _selfEsteemProudness = 0;
  int _lookingForwardToWakeUpTomorrow = 0;
  String? _enteredRecap;
  String? _enteredImprovement;

  @override
  void initState() {
    super.initState();
    if (widget.oldTrackedDay != null) {
      // Initialize the values if an old tracked day is provided
      _sleepQuality = widget.oldTrackedDay!.sleepQuality;
      _wellBeing = widget.oldTrackedDay!.wellBeing;
      _energy = widget.oldTrackedDay!.energy;
      _driveMotivation = widget.oldTrackedDay!.driveMotivation;
      _stress = widget.oldTrackedDay!.stress;
      _focusMentalClarity = widget.oldTrackedDay!.focusMentalClarity;
      _intelligenceMentalPower = widget.oldTrackedDay!.intelligenceMentalPower;
      _frustrations = widget.oldTrackedDay!.frustrations;
      _satisfaction = widget.oldTrackedDay!.satisfaction;
      _selfEsteemProudness = widget.oldTrackedDay!.selfEsteemProudness;
      _lookingForwardToWakeUpTomorrow =
          widget.oldTrackedDay!.lookingForwardToWakeUpTomorrow;
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

  Color? getRatingColorMap(double value) {
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

    // Create a new tracked day
    RecapDay newRecapDay = RecapDay(
      sleepQuality: _sleepQuality,
      wellBeing: _wellBeing,
      energy: _energy,
      driveMotivation: _driveMotivation,
      stress: _stress,
      focusMentalClarity: _focusMentalClarity,
      intelligenceMentalPower: _intelligenceMentalPower,
      frustrations: _frustrations,
      satisfaction: _satisfaction,
      selfEsteemProudness: _selfEsteemProudness,
      lookingForwardToWakeUpTomorrow: _lookingForwardToWakeUpTomorrow,
      date: widget.date, // Assuming 'date' is now, adjust accordingly
      recap: _enteredRecap,
      improvements: _enteredImprovement,
    );

    Navigator.of(context).pop();

    if (widget.oldTrackedDay == null) {
      // Add new tracked day
      ref.read(recapDayProvider.notifier).addRecapDay(newRecapDay);
    } else {
      // Update the tracked day
      ref.read(recapDayProvider.notifier).updateRecapDay(newRecapDay);
    }

    TrackedDay trackedDay = TrackedDay(
        habitId: widget.habitId,
        date: widget.date,
        done: Validated.yes,
      );

      ref.read(trackedDayProvider.notifier).addTrackedDay(trackedDay);

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
                  Text(
                    'Activity Evaluation',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
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

              // Slider for Sleep Quality
              const ToolTipTittle("Sleep Quality", "Rate your sleep quality"),
              Slider(
                activeColor: getRatingColorMap(_sleepQuality.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _sleepQuality.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _ratingText[_sleepQuality],
                onChanged: (value) {
                  setState(() {
                    _sleepQuality = value.toInt();
                  });
                },
              ),

              // Slider for Well-being
              const ToolTipTittle("Well-being", "Rate your well-being"),
              Slider(
                activeColor: getRatingColorMap(_wellBeing.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _wellBeing.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _ratingText[_wellBeing],
                onChanged: (value) {
                  setState(() {
                    _wellBeing = value.toInt();
                  });
                },
              ),

              // Slider for Energy
              const ToolTipTittle("Energy", "Rate your energy level"),
              Slider(
                activeColor: getRatingColorMap(_energy.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _energy.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _energy.toString(),
                onChanged: (value) {
                  setState(() {
                    _energy = value.toInt();
                  });
                },
              ),

              // Slider for Drive/Motivation
              const ToolTipTittle("Drive / Motivation", "Rate your motivation"),
              Slider(
                activeColor: getRatingColorMap(_driveMotivation.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _driveMotivation.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _driveMotivation.toString(),
                onChanged: (value) {
                  setState(() {
                    _driveMotivation = value.toInt();
                  });
                },
              ),

              // Slider for Stress
              const ToolTipTittle("Stress", "Rate your stress level"),
              Slider(
                activeColor: getRatingColorMap(_stress.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _stress.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _stress.toString(),
                onChanged: (value) {
                  setState(() {
                    _stress = value.toInt();
                  });
                },
              ),

              // Slider for Focus/Mental Clarity
              const ToolTipTittle("Focus / Mental Clarity", "Rate your focus"),
              Slider(
                activeColor: getRatingColorMap(_focusMentalClarity.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _focusMentalClarity.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _focusMentalClarity.toString(),
                onChanged: (value) {
                  setState(() {
                    _focusMentalClarity = value.toInt();
                  });
                },
              ),

              // Slider for Intelligence/Mental Power
              const ToolTipTittle(
                  "Intelligence / Mental Power", "Rate your mental power"),
              Slider(
                activeColor:
                    getRatingColorMap(_intelligenceMentalPower.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _intelligenceMentalPower.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _intelligenceMentalPower.toString(),
                onChanged: (value) {
                  setState(() {
                    _intelligenceMentalPower = value.toInt();
                  });
                },
              ),

              // Slider for Frustrations
              const ToolTipTittle("Frustrations", "Rate your frustrations"),
              Slider(
                activeColor: getRatingColorMap(_frustrations.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _frustrations.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _frustrations.toString(),
                onChanged: (value) {
                  setState(() {
                    _frustrations = value.toInt();
                  });
                },
              ),

              // Slider for Satisfaction
              const ToolTipTittle("Satisfaction", "Rate your satisfaction"),
              Slider(
                activeColor: getRatingColorMap(_satisfaction.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _satisfaction.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _satisfaction.toString(),
                onChanged: (value) {
                  setState(() {
                    _satisfaction = value.toInt();
                  });
                },
              ),

              // Slider for Self-Esteem/Proudness
              const ToolTipTittle(
                  "Self-Esteem / Proudness", "Rate your self-esteem"),
              Slider(
                activeColor: getRatingColorMap(_selfEsteemProudness.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _selfEsteemProudness.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _selfEsteemProudness.toString(),
                onChanged: (value) {
                  setState(() {
                    _selfEsteemProudness = value.toInt();
                  });
                },
              ),

              // Slider for Looking forward to wake-up tomorrow
              const ToolTipTittle("Looking forward to wake-up tomorrow",
                  "Rate your eagerness to wake up tomorrow"),
              Slider(
                activeColor: getRatingColorMap(
                    _lookingForwardToWakeUpTomorrow.toDouble()),
                inactiveColor: Theme.of(context).colorScheme.surfaceBright,
                value: _lookingForwardToWakeUpTomorrow.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                label: _lookingForwardToWakeUpTomorrow.toString(),
                onChanged: (value) {
                  setState(() {
                    _lookingForwardToWakeUpTomorrow = value.toInt();
                  });
                },
              ),

              const SizedBox(height: 32),

              // Text Field for Recap
              const ToolTipTittle("Recap", "Provide a summary of your day"),
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

              // Text Field for Improvements
              const ToolTipTittle(
                  "Improvements", "Provide suggestions for improvement"),
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
              const SizedBox(height: 8),

              // Text Field for Gratitude
              const ToolTipTittle(
                  "What am I grateful for?", "Write what you're grateful for"),
              TextFormField(
                minLines: 3,
                maxLines: 3,
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  // Handle the saved gratitude value here
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

              // Text Field for Proudness / Difficult thing
              const ToolTipTittle("What am I proud of / Challenges overcomed?",
                  "Write what you're proud of or a difficult thing you accomplished"),
              TextFormField(
                minLines: 3,
                maxLines: 3,
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  // Handle the saved proudness/difficult thing value here
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

              // Submit Button
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
