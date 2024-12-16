import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/display/modify_habit.dart';
import 'package:tracker_v1/global/logic/capitalize_string.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/new_habit/data/frequency_state.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/new_habit/display/additional_metrics_widget.dart';
import 'package:tracker_v1/new_habit/display/frequency_picker2_widget.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/display/big_text_form_field_widget.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';

class NewHabitScreen extends ConsumerStatefulWidget {
  const NewHabitScreen({this.habit, this.dateOpened, super.key});

  final Habit? habit;
  final DateTime? dateOpened;

  @override
  ConsumerState<NewHabitScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<NewHabitScreen> {
  final formKey = GlobalKey<FormState>();
  dynamic notifier;
  Schedule? oldSchedule;

  @override
  void initState() {
    // Load the habit data if editing existing habit
    if (widget.habit != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(newHabitProvider.notifier).setState(widget.habit!.copy());

        if (widget.dateOpened != null) {
          Schedule targetDaySchedule = ref
              .read(scheduledProvider.notifier)
              .getHabitTargetDaySchedule(widget.habit!, widget.dateOpened!);
          oldSchedule = targetDaySchedule;
          ref
              .read(frequencyProvider.notifier)
              .setState(targetDaySchedule.copyWith());
        } else {
          Schedule defaultSchedule = ref
              .read(scheduledProvider.notifier)
              .getHabitDefaultSchedule(widget.habit!);
          oldSchedule = defaultSchedule;
          ref
              .read(frequencyProvider.notifier)
              .setState(defaultSchedule.copyWith());
        }
      });
    }

    // Set the start date if created / edited from the dailyscreen
    if (widget.dateOpened != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(frequencyProvider.notifier).setStartDate(widget.dateOpened!);
        ref.read(frequencyProvider.notifier).setDaysOfTheWeek([
          DaysOfTheWeekUtility.NumberToWeekDay[widget.dateOpened!.weekday]!
        ]);
      });
    }

    super.initState();
    notifier = ref.read(newHabitProvider.notifier);
  }

  @override
  Widget build(BuildContext context) {
    Habit habitState = ref.watch(newHabitProvider);
    Schedule frequencyState = ref.watch(frequencyProvider);

    return CustomModalBottomSheet(
      title: widget.habit != null ? 'Edit Habit' : 'New Habit',
      formKey: formKey,
      content: Column(
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconPickerWidget(),
            const SizedBox(width: 16),
            _getName(habitState),
          ]),
          _getColorPicker(habitState),
          const SizedBox(height: 12),
          _getDescriptionField(habitState),
          const SizedBox(height: 16),
          _getPriorityField(habitState),
          const SizedBox(height: 32),
          FrequencyPickerWidget(),
          const SizedBox(height: 32),
          _getTimeOfTheDayField(frequencyState),
          const SizedBox(height: 32),
          _getHabitType(habitState),
          const SizedBox(height: 32),
          AnimatedSwitcher(
              transitionBuilder: (switcherChild, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: switcherChild,
                  ),
                );
              },
              duration: Duration(milliseconds: 300),
              child: habitState.validationType == HabitType.recap
                  ? _getImprovementField(habitState)
                  : null),
          AdditionalMetrics(habitState.additionalMetrics!),
          const SizedBox(height: 32),
          CustomElevatedButton(
            color: habitState.color,
            submit: () => _submit(context),
            text: widget.habit != null ? 'Edit' : 'Create',
          )
        ],
      ),
    );
  }

  Widget _getName(habitState) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BigTextFormField(
          color: habitState.color,
          maxLenght: 100,
          maxLine: 1,
          controlledValue: habitState.name,
          onSaved: (value) {
            notifier.setName(value);
          },
          toolTipTitle: 'Name:',
          tooltipContent: 'Provide a name of this habit',
        ),
      ],
    ));
  }

  Widget _getColorPicker(habitState) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        const CustomToolTipTitle(
            title: 'Color:', content: 'Select the color of the stat'),
        Spacer(),
        Center(
          child: InkWell(
            onTap: _showColorPicker,
            child: CircleAvatar(
              backgroundColor: habitState.color,
              radius: 24,
            ),
          ),
        ),
        Spacer(),
      ],
    );
  }

  void _showColorPicker() {
    Habit habitState = ref.watch(newHabitProvider);

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
            backgroundColor: Colors.black,
            content: BlockPicker(
                pickerColor: habitState.color,
                onColorChanged: (value) {
                  setState(() {
                    notifier.setColor(value);
                  });
                  Navigator.of(ctx).pop();
                })));
  }

  Widget _getDescriptionField(habitState) {
    return BigTextFormField(
      color: habitState.color,
      controlledValue: habitState.description,
      onSaved: (value) {
        notifier.setDescription(value);
      },
      toolTipTitle: 'Description:',
      tooltipContent: 'Provide a description of this habit',
    );
  }

  Widget _getPriorityField(habitState) {
    return Row(
      children: [
        const CustomToolTipTitle(title: 'Priority:', content: 'Importance'),
        Expanded(
          child: Center(
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    borderRadius: BorderRadius.circular(5)),
                child: DropdownButton(
                  value: habitState.ponderation,
                  icon: const Icon(Icons.arrow_drop_down),
                  isDense: true,
                  dropdownColor: Theme.of(context).colorScheme.surfaceBright,
                  items: Ponderation.values.reversed
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.index + 1,
                          child: Text(item.name.toString().capitalizeString()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      notifier.setPonderation(value);
                    });
                  },
                )),
          ),
        ),
      ],
    );
  }

  Widget _getTimeOfTheDayField(Schedule frequencyState) {
    return Row(children: [
      const CustomToolTipTitle(title: 'Time of the day:', content: 'Time'),
      Expanded(
        child: Center(
          child: ElevatedButton(
            onPressed: () async {
              ref.read(frequencyProvider.notifier).setTimesOfTheDay(
                  await showTimePicker(
                      context: context,
                      initialTime:
                          frequencyState.timesOfTheDay?[0] ?? TimeOfDay.now(),
                      initialEntryMode: TimePickerEntryMode.input));
            },
            style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                backgroundColor: Theme.of(context).colorScheme.surfaceBright),
            child: Text(
              frequencyState.timesOfTheDay == null
                  ? 'Whenever'
                  : frequencyState.timesOfTheDay![0].format(context),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      )
    ]);
  }

  Widget _getHabitType(habitState) {
    List<HabitType> habitTypeList = _generateHabitTypeList();
    return Row(
      children: [
        const CustomToolTipTitle(title: 'Habit type:', content: 'Item type'),
        Expanded(
          child: Center(
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceBright,
                    borderRadius: BorderRadius.circular(5)),
                child: DropdownButton(
                  value: habitState.validationType,
                  icon: const Icon(Icons.arrow_drop_down),
                  isDense: true,
                  dropdownColor: Theme.of(context).colorScheme.surfaceBright,
                  items: habitTypeList
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(habitTypeDescriptions[item] ?? ''),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    notifier.setValidationType(value);
                  },
                )),
          ),
        ),
      ],
    );
  }

  List<HabitType> _generateHabitTypeList() {
    List<HabitType> habitTypeList = List.from(HabitType.values);

    if (ref.read(habitProvider).firstWhereOrNull(
                (h) => h.validationType == HabitType.recapDay) !=
            null &&
        widget.habit != null &&
        widget.habit!.validationType != HabitType.recapDay) {
      habitTypeList.remove(HabitType.recapDay);
    }

    return habitTypeList;
  }

  Widget _getImprovementField(habitState) {
    return BigTextFormField(
      color: habitState.color,
      maxLenght: 100,
      maxLine: 1,
      controlledValue: habitState.newHabit,
      onSaved: (value) {
        notifier.setMainImprovement(value);
      },
      toolTipTitle: 'Weekly focus:',
      tooltipContent: 'Main improvement',
    );
  }

  void _submit(context) {
    if (!formKey.currentState!.validate()) {
      return;
    }
    formKey.currentState!.save();
    Habit newHabit = ref.read(newHabitProvider);

    if (widget.habit != null) {
      Schedule newSchedule = ref.read(frequencyProvider);
      bool noScheduleChange = Schedule.compareSchedules(newSchedule, oldSchedule!);
      bool noHabitChange = Habit.compare(widget.habit!, newHabit);
      if (!noScheduleChange) {
        showModifyHabitDialog(context, ref, ref.read(frequencyProvider));
      }

      if (!noHabitChange) {
        ref.read(habitProvider.notifier).updateHabit(widget.habit!, newHabit);

      }

      if (noScheduleChange) {
         Navigator.of(context).pop();
      } 
    } else {
      ref.read(habitProvider.notifier).addHabit(newHabit);
      ref.read(frequencyProvider.notifier).setHabitId(newHabit.habitId);
      ref
          .read(scheduledProvider.notifier)
          .addSchedule(ref.read(frequencyProvider));
      Navigator.of(context).pop();
    }
  }
}

class IconPickerWidget extends ConsumerWidget {
  const IconPickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Habit habitState = ref.read(newHabitProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Icon:',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Colors.white.withOpacity(0.75))),
        IconButton(
            icon: Icon(
              habitState.icon,
              color: habitState.color,
            ),
            iconSize: 40,
            onPressed: () async {
              IconPickerIcon? iconPicker = await showIconPicker(context,
                  configuration: SinglePickerConfiguration(
                      iconPackModes: [IconPack.roundedMaterial],
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceBright
                          .withOpacity(1)));

              if (iconPicker == null) return;
              IconData icon = iconPicker.data;
              ref.read(newHabitProvider.notifier).setIcon(icon);
            }),
      ],
    );
  }
}
