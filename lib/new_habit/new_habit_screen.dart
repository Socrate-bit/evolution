import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/daily/data/daily_screen_state.dart';
import 'package:tracker_v1/global/data/page_enum.dart';
import 'package:tracker_v1/global/data/schedule_cache.dart';
import 'package:tracker_v1/global/display/animations.dart';
import 'package:tracker_v1/global/display/modify_habit_dialog.dart';
import 'package:tracker_v1/global/logic/capitalize_string.dart';
import 'package:tracker_v1/global/logic/first_where_or_null.dart';
import 'package:tracker_v1/habit/data/habits_provider.dart';
import 'package:tracker_v1/habit_bank/data/shared_habit_stats_model.dart';
import 'package:tracker_v1/habit_bank/data/shared_habit_stats_provider.dart';
import 'package:tracker_v1/habit_bank/data/shared_habit_stats_state.dart';
import 'package:tracker_v1/habit_bank/data/shared_habits_provider.dart';
import 'package:tracker_v1/new_habit/data/frequency_state.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';
import 'package:tracker_v1/new_habit/data/scheduled_provider.dart';
import 'package:tracker_v1/new_habit/display/additional_metrics_widget.dart';
import 'package:tracker_v1/new_habit/display/category_impact_widget.dart';
import 'package:tracker_v1/new_habit/display/duration_picker_widget.dart';
import 'package:tracker_v1/new_habit/display/frequency_picker2_widget.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/display/big_text_form_field_widget.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';
import 'package:tracker_v1/notifications/display/notification_widget.dart.dart';
import 'package:tracker_v1/new_habit/display/time_picker_widget.dart';

class NewHabitScreen extends ConsumerStatefulWidget {
  const NewHabitScreen({this.habit, this.navigation, super.key});

  final Habit? habit;
  final HabitListNavigation? navigation;

  @override
  ConsumerState<NewHabitScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<NewHabitScreen> {
  final formKey = GlobalKey<FormState>();
  late NewHabitState notifier;
  Schedule? oldSchedule;
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    notifier = ref.read(newHabitStateProvider.notifier);
    selectedDay = ref.read(dailyScreenStateProvider).selectedDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHabitState();
      _initScheduleState();
    });
  }

  void _initHabitState() {
    if (widget.habit != null) {
      ref.read(newHabitStateProvider.notifier).setState(widget.habit!.copy());
    }
  }

  void _initScheduleState() {
    switch (widget.navigation) {
      case HabitListNavigation.addHabit:
        if (widget.habit != null) {
          oldSchedule = ref.read(scheduleCacheProvider(null))[widget.habit]?.$1;

          // If existing pre-created schedule
          if (oldSchedule != null && oldSchedule?.startDate == null) {
            ref
                .read(frequencyStateProvider.notifier)
                .setState(oldSchedule!.copyWith());
          }
        }

        ref.read(frequencyStateProvider.notifier).setStartDate(selectedDay);

      case HabitListNavigation.habitList:
        oldSchedule = ref.read(scheduleCacheProvider(null))[widget.habit!]?.$1;

        if (oldSchedule != null) {
          ref
              .read(frequencyStateProvider.notifier)
              .setState(oldSchedule!.copyWith());
        }

      case HabitListNavigation.dailyScreen:
        oldSchedule =
            ref.read(scheduleCacheProvider(selectedDay))[widget.habit!]?.$1;

        ref
            .read(frequencyStateProvider.notifier)
            .setState(oldSchedule!.copyWith());
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Habit habitState = ref.watch(newHabitStateProvider);
    Schedule scheduleState = ref.watch(frequencyStateProvider);

    Widget contentScheduleOnly = Column(
      children: [
        FrequencyPickerWidget(),
        const SizedBox(height: 32),
        TimeOfTheDayField(),
        const SizedBox(height: 32),
        CustomElevatedButton(
          color: habitState.color,
          submit: () => _submit(context),
          text: _getSubmitButtonText(),
        ),
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
            child: scheduleState.timesOfTheDay != null &&
                    scheduleState.timesOfTheDay!
                        .where((t) => t != null)
                        .isNotEmpty
                ? NotificationField()
                : null),
        SizedBox(height: 8)
      ],
    );

    Widget contentFull = Column(
      children: [
        if (widget.navigation == HabitListNavigation.shareHabit) ...[
          CategoryImpactField(),
          const SizedBox(height: 8)
        ],
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          IconPickerWidget(),
          const SizedBox(width: 16),
          _getNameField(habitState),
        ]),
        _getColorPickerField(habitState),
        const SizedBox(height: 12),
        _getDescriptionField(habitState),
        const SizedBox(height: 32),
        DurationPickerWidget(),
        const SizedBox(height: 48),
        _getHabitTypeField(habitState),
        SizedBox(
            height: habitState.validationType == HabitType.recap ? 32 : 16),
        SwitcherAnimation(habitState.validationType == HabitType.recap
            ? _getImprovementField(habitState)
            : null),
        SizedBox(
            height: habitState.validationType == HabitType.recap ? 32 : 16),
        _getPriorityField(habitState),
        const SizedBox(height: 32),
        FrequencyPickerWidget(),
        const SizedBox(height: 32),
        TimeOfTheDayField(),
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
            child: scheduleState.timesOfTheDay != null &&
                    scheduleState.timesOfTheDay!
                        .where((t) => t != null)
                        .isNotEmpty
                ? NotificationField()
                : null),
        AdditionalMetricsField(),
        const SizedBox(height: 16),
        CustomElevatedButton(
          color: habitState.color,
          submit: () => _submit(context),
          text: _getSubmitButtonText(),
        ),
        SizedBox(height: 8),
        if (widget.habit == null)
          TextButton(
            onPressed: () {
              ref.read(frequencyStateProvider.notifier).setStartDate(null);
              _submit(context);
            },
            child: Text('Plan later',
                maxLines: 2,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: ref.read(newHabitStateProvider).color)),
          ),
        SizedBox(height: 8),
      ],
    );

    return CustomModalBottomSheet(
        title: _getModalSheetName(),
        formKey: formKey,
        content: (widget.navigation == HabitListNavigation.addHabit &&
                widget.habit != null)
            ? contentScheduleOnly
            : contentFull);
  }

  String _getModalSheetName() {
    if (widget.navigation == HabitListNavigation.addHabit) {
      return 'Create Routine';
    }
    return widget.habit != null ? 'Edit Task' : 'New Task';
  }

  Widget _getNameField(Habit habitState) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BigTextFormField(
          color: habitState.color,
          maxLenght: 100,
          minLine: 1,
          maxLine: 1,
          controlledValue: habitState.name,
          onSaved: (value) {
            notifier.setName(value ?? '');
          },
          toolTipTitle: 'Name:',
          tooltipContent: 'Provide a name of this habit',
        ),
      ],
    ));
  }

  Widget _getColorPickerField(habitState) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        const CustomToolTipTitle(
            title: 'Color:', content: 'Select the color of the stat'),
        Spacer(),
        Center(
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              _showColorPicker();
            },
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
    Habit habitState = ref.read(newHabitStateProvider);

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
      minLine: 3,
      maxLine: 20,
      color: habitState.color,
      controlledValue: habitState.description,
      onSaved: (value) {
        notifier.setDescription(value ?? '');
      },
      toolTipTitle: 'Description:',
      tooltipContent: 'Provide a description of this habit',
    );
  }

  Widget _getPriorityField(habitState) {
    return Row(
      children: [
        const CustomToolTipTitle(title: 'Priority:', content: 'Importance'),
        Spacer(),
        Center(
          child: Container(
              height: 40,
              width: 175,
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
                onTap: () => HapticFeedback.selectionClick(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    notifier.setPonderation(value as int);
                  });
                },
              )),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _getHabitTypeField(habitState) {
    List<HabitType> habitTypeList = _generateHabitTypeList();
    return Row(
      children: [
        const CustomToolTipTitle(title: 'Task Type:', content: 'Item type'),
        Spacer(),
        Center(
          child: Container(
              height: 40,
              width: 175,
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
                onTap: () => HapticFeedback.selectionClick(),
                onChanged: (value) {
                  if (value == null) return;
                  notifier.setValidationType(value as HabitType);
                },
              )),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  List<HabitType> _generateHabitTypeList() {
    List<HabitType> habitTypeList = List.from(HabitType.values);

    if (ref.read(habitProvider).firstWhereOrNull(
                (h) => h.validationType == HabitType.recapDay) !=
            null &&
        (widget.habit != null
            ? widget.habit!.validationType != HabitType.recapDay
            : true)) {
      habitTypeList.remove(HabitType.recapDay);
    }

    habitTypeList.remove(HabitType.unique);

    return habitTypeList;
  }

  Widget _getImprovementField(Habit habitState) {
    return BigTextFormField(
      color: habitState.color,
      maxLenght: 100,
      minLine: 1,
      maxLine: 1,
      controlledValue: habitState.newHabit ?? '',
      onSaved: (value) {
        notifier.setMainImprovement(value ?? '');
      },
      toolTipTitle: 'Weekly focus:',
      tooltipContent: 'Main improvement',
    );
  }

  String _getSubmitButtonText() {
    String text;

    if (widget.habit != null) {
      text = oldSchedule?.startDate == null ? 'Create Task' : 'Edit';
    } else {
      text = 'Create';
    }

    return text;
  }

  void _submit(context) {
    if (!formKey.currentState!.validate()) {
      return;
    }

    formKey.currentState!.save();

    Habit newHabit = ref.read(newHabitStateProvider);
    ref.read(frequencyStateProvider.notifier).setHabitId(newHabit.habitId);
    Schedule newSchedule = ref.read(frequencyStateProvider);

    if (widget.navigation == HabitListNavigation.shareHabit) {
      _submitShared(newHabit, newSchedule);
    } else {
      _submitUserHabit(newHabit, newSchedule);
    }
    Navigator.of(context).pop();
  }

  void _submitShared(Habit newSharedHabit, Schedule newSchedule) {
    ref.read(newHabitStateProvider.notifier).setShared();
    SharedHabitStats sharedHabitStats = ref.read(sharedHabitStateProvider);

    sharedHabitStats.habitId = newSharedHabit.habitId;

    ref
        .read(sharedHabitStatsProvider.notifier)
        .addSharedHabitStats(sharedHabitStats);

    ref
        .read(sharedHabitsProvider.notifier)
        .addSharedHabitSchedule(newSharedHabit, newSchedule);
  }

  void _submitUserHabit(Habit newHabit, Schedule newSchedule) {
    _updateHabit(habitProvider.notifier, newHabit);
    _updateSchedule(newSchedule);

    if (widget.navigation == HabitListNavigation.addHabit) {
      Navigator.of(context).pop();
      if (widget.habit != null) {
        Navigator.of(context).pop();
      }
    }
  }

  void _updateHabit(ProviderListenable provider, Habit newHabit) {
    if (widget.habit != null) {
      bool noHabitChange = Habit.compare(widget.habit!, newHabit);
      if (!noHabitChange) {
        ref.read(provider).updateHabit(widget.habit!, newHabit);
      }
    } else {
      ref.read(provider).addHabit(newHabit);
    }
  }

  void _updateSchedule(Schedule newSchedule) {
    if (oldSchedule != null) {
      bool noScheduleChange =
          Schedule.compareSchedules(newSchedule, oldSchedule);
      if (!noScheduleChange) {
        Schedule? defaultSchedule =
            ref.read(scheduleCacheProvider(null))[widget.habit]!.$1;
        if (defaultSchedule?.type == FrequencyType.Once) {
          newSchedule.resetScheduleId();
          ref.read(scheduledProvider.notifier).modifyTodayOnly(newSchedule);
          popUntilDailyScreen(context);
        } else {
          showModifyHabitDialog(context, ref, ref.read(frequencyStateProvider));
        }
        return;
      }
    } else {
      ref
          .read(scheduledProvider.notifier)
          .addSchedule(ref.read(frequencyStateProvider));
    }
  }
}

class IconPickerWidget extends ConsumerWidget {
  const IconPickerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Habit habitState = ref.read(newHabitStateProvider);

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
              HapticFeedback.selectionClick();
              IconPickerIcon? iconPicker = await showIconPicker(context,
                  configuration: SinglePickerConfiguration(
                      iconPackModes: [IconPack.roundedMaterial],
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceBright
                          .withOpacity(1)));

              if (iconPicker == null) return;
              IconData icon = iconPicker.data;
              ref.read(newHabitStateProvider.notifier).setIcon(icon);
            }),
      ],
    );
  }
}
