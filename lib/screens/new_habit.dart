import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/widgets/circle_day.dart';
import 'package:tracker_v1/models/habit.dart';


class NewHabitScreen extends ConsumerStatefulWidget {
  const NewHabitScreen({super.key});

  @override
  ConsumerState<NewHabitScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<NewHabitScreen> {
  final formKey = GlobalKey<FormState>();

  IconData _enteredIcon = Icons.self_improvement;
  String? _enteredName;
  String? _entereDescription;
  int _enteredFrequency = 1;
  final List<WeekDay> _enteredWeekdays = [];
  ValidationType _enteredValidationType = ValidationType.binary;
  bool _frequencyType = false;
  DateTime? _enteredStartDate;
  DateTime? _enteredEndDate;
  final List<String> _enteredAdditionalMetrics = [];
  final _additionalInputController = TextEditingController();
  DateTime today = DateTime.now();

  final _formater = DateFormat.yMd();

  Future<DateTime?> _datePicker() async {
    DateTime lastDate = DateTime(today.year + 1, today.month, today.day);

    DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: today,
        lastDate: lastDate,
        initialDate: today);

    if (pickedDate == null) return null;

    return pickedDate;
  }

  void _addAdditionalMetrics(context) {
    if (_enteredAdditionalMetrics.length > 4) {
      showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                content: const Text("Maximum additional fields reached..."),
                backgroundColor: Theme.of(context).colorScheme.surfaceBright,
                contentTextStyle: const TextStyle(color: Colors.white),
              ));
      return;
    }
    setState(() {
      _enteredAdditionalMetrics.add(_additionalInputController.text);
      _additionalInputController.clear();
    });
  }

  @override
  void dispose() {
    _additionalInputController.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();

    if (_enteredWeekdays.isNotEmpty) {
      _enteredFrequency = _enteredWeekdays.length;
    }

    Habit newHabit = Habit(
        userId: '123456789',
        icon: _enteredIcon,
        name: _enteredName!,
        description: _entereDescription,
        frequency: _enteredFrequency,
        weekdays:
            _enteredWeekdays.isEmpty ? [...WeekDay.values] : _enteredWeekdays,
        validationType: _enteredName == 'Daily recap'
            ? ValidationType.recapDay
            : _enteredValidationType,
        startDate:
            _enteredStartDate ?? DateTime(today.year, today.month, today.day),
        endDate: _enteredEndDate,
        additionalMetrics: _enteredAdditionalMetrics);

    Navigator.of(context).pop();
    ref.read(habitProvider.notifier).addHabit(newHabit);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('New Habit',
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Icon',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: Colors.white),
                      ),
                      IconButton(
                          iconSize: 40,
                          onPressed: () async {
                            IconData? icon = await showIconPicker(context,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceBright
                                    .withOpacity(1));

                            if (icon == null) return;
                            setState(() {
                              _enteredIcon = icon;
                            });
                          },
                          icon: Icon(_enteredIcon))
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Invalid name";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredName = value;
                        },
                        maxLength: 30,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceBright
                              .withOpacity(0.5),
                          label: const Text("Name"),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _entereDescription = value;
                },
                maxLength: 100,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceBright
                      .withOpacity(0.5),
                  label: const Text("Description (Optional)"),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                  subtitle: Text(_frequencyType
                      ? 'Switch to specific days:'
                      : "Switch to random days:"),
                  title: const Text("Frequency"),
                  value: _frequencyType,
                  onChanged: (value) {
                    setState(() {
                      _frequencyType = value;
                    });
                  }),
              if (_frequencyType)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceBright,
                      borderRadius: BorderRadius.circular(5)),
                  child: DropdownButton(
                    value: _enteredFrequency,
                    icon: const Icon(Icons.arrow_drop_down),
                    isDense: true,
                    dropdownColor: Theme.of(context).colorScheme.surfaceBright,
                    items: [for (int i = 1; i < 8; i++) i]
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              '$item time${item > 1 ? "s" : ""} per week',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _enteredFrequency = value;
                      });
                    },
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleToggleDay(_enteredWeekdays, WeekDay.monday),
                    const SizedBox(width: 10),
                    CircleToggleDay(_enteredWeekdays, WeekDay.tuesday),
                    const SizedBox(width: 10),
                    CircleToggleDay(_enteredWeekdays, WeekDay.wednesday),
                    const SizedBox(width: 10),
                    CircleToggleDay(_enteredWeekdays, WeekDay.thursday),
                    const SizedBox(width: 10),
                    CircleToggleDay(_enteredWeekdays, WeekDay.friday),
                    const SizedBox(width: 10),
                    CircleToggleDay(_enteredWeekdays, WeekDay.saturday),
                    const SizedBox(width: 10),
                    CircleToggleDay(_enteredWeekdays, WeekDay.sunday),
                    const SizedBox(width: 10),
                  ],
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                subtitle: Text(
                    _enteredValidationType == ValidationType.evaluation
                        ? 'Switch to simple habit:'
                        : "Switch to activity:"),
                title: const Text("Habit type"),
                value: _enteredValidationType == ValidationType.evaluation,
                onChanged: (value) {
                  setState(
                    () {
                      if (value == true) {
                        _enteredValidationType = ValidationType.evaluation;
                      } else {
                        _enteredValidationType = ValidationType.binary;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _additionalInputController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceBright
                            .withOpacity(0.5),
                        label: const Text("Additional tracking (Optional)"),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        _addAdditionalMetrics(context);
                      },
                      icon: const Icon(Icons.add)),
                  SizedBox(
                    height: 60,
                    width: 70,
                    child: _enteredAdditionalMetrics.isNotEmpty
                        ? ListView.builder(
                            itemCount: _enteredAdditionalMetrics.length,
                            itemBuilder: (ctx, item) {
                              return Text(
                                _enteredAdditionalMetrics[item],
                                style: const TextStyle(color: Colors.white),
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            })
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () async {
                        _enteredStartDate = await _datePicker();
                        setState(
                          () {},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceBright),
                      child: Text(
                        _enteredStartDate == null
                            ? 'Start date'
                            : _formater.format(_enteredStartDate!).toString(),
                        style: const TextStyle(color: Colors.white),
                      )),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        _enteredEndDate = await _datePicker();
                        setState(
                          () {},
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          backgroundColor:
                              Theme.of(context).colorScheme.surfaceBright),
                      child: Text(
                          _enteredEndDate == null
                              ? 'End date (Optional)'
                              : _formater.format(_enteredEndDate!).toString(),
                          style: const TextStyle(color: Colors.white)))
                ],
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        spreadRadius: 0.5,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ]),
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      child: Text(
                        'Create',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
