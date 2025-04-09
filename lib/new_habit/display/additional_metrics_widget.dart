import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';
import 'package:tracker_v1/new_habit/display/card_list_widget.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/global/display/big_text_form_field_widget.dart';

class AdditionalMetricsField extends ConsumerWidget {
  const AdditionalMetricsField();

  List<TitledCardItem> _getTitlesCardItems(
      Habit habitState, BuildContext context, WidgetRef ref) {
    if (habitState.additionalMetrics == null) {
      return [];
    }

    return habitState.additionalMetrics!.map((additionalMetric) {
      Icon icon = Icon(
        habitState.icon,
        color: habitState.color,
      );

      Text text = Text(
        additionalMetric,
        softWrap: true,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge,
      );

      IconButton iconButton = IconButton(
          onPressed: () {
            int index = habitState.additionalMetrics!.indexOf(additionalMetric);
            HapticFeedback.selectionClick();
            ref
                .read(newHabitStateProvider.notifier)
                .removeAdditionalMetrics(index);
          },
          icon: const Icon(
            Icons.delete,
            size: 20,
            color: Colors.grey,
          ));

      return TitledCardItem(leading: icon, title: text, trailing: iconButton);
    }).toList();
  }

  void _addAdditionalMetrics(context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => CustomModalBottomSheet(
              content: _NewMetricModal(),
              title: 'Add Tracking',
            ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Habit habitState = ref.watch(newHabitStateProvider);

    return TitledCardList(
        title: 'Additional Tracking:',
        items: _getTitlesCardItems(habitState, context, ref),
        addTap: () {
          _addAdditionalMetrics(context);
        },
        addColor: habitState.color,
        addTitle: 'Add Tracking');

  }
}

class _NewMetricModal extends ConsumerStatefulWidget {
  @override
  ConsumerState<_NewMetricModal> createState() => _NewMetricModalState();
}

class _NewMetricModalState extends ConsumerState<_NewMetricModal> {
  String? additionalMetrics;

  @override
  Widget build(BuildContext context) {
    Habit habitState = ref.watch(newHabitStateProvider);

    return Column(
      children: [
        BigTextFormField(
          color: habitState.color,
          maxLenght: 100,
          maxLine: 1,
          minLine: 1,
          controlledValue: additionalMetrics ?? '',
          onSaved: (value) {
            additionalMetrics = value;
          },
          toolTipTitle: 'Name:',
          tooltipContent: 'Provide Additional tracking (Optional)',
        ),
        const SizedBox(height: 32),
        CustomElevatedButton(
          submit: () {
            ref
                .read(newHabitStateProvider.notifier)
                .addAdditionalMetrics(additionalMetrics!);
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
