import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/display/big_text_form_field_widget.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/data/new_habit_state.dart';

class AdditionalMetrics extends ConsumerWidget {
  const AdditionalMetrics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Habit habitState = ref.watch(newHabitStateProvider);
    int additionalMetricsLength =
        (habitState.additionalMetrics?.length ?? 0) + 1;

    return SizedBox(
      child: Column(
        children: [
          CustomToolTipTitle(
              title: 'Additional Tracking:', content: 'Additional Tracking'),
          const SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            itemCount: additionalMetricsLength,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, item) {
              if (item == additionalMetricsLength - 1) {
                return _NewAdditionalMetricCard();
              }
              return _AdditionalMetricCard(
                item: item,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AdditionalMetricCard extends ConsumerWidget {
  final int item;

  const _AdditionalMetricCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Habit habitState = ref.watch(newHabitStateProvider);
    List<String>? enteredAdditionalMetrics = habitState.additionalMetrics;

    return BasicCard(
      child: ListTile(
        leading: Icon(
          habitState.icon,
          color: habitState.color,
        ),
        title: Text(
          enteredAdditionalMetrics![item],
          softWrap: true,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        trailing: IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              ref
                .read(newHabitStateProvider.notifier)
                .removeAdditionalMetrics(item);},
            icon: const Icon(
              Icons.delete,
              size: 20,
              color: Colors.grey,
            )),
      ),
    );
  }
}

class _NewAdditionalMetricCard extends ConsumerWidget {
  const _NewAdditionalMetricCard();

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

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        _addAdditionalMetrics(context);
      },
      child: BasicCard(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_box_rounded,
              size: 20,
              color: habitState.color,
            ),
            const SizedBox(width: 8),
            Text(
              'Add Tracking',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: habitState.color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
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

class BasicCard extends StatelessWidget {
  final Widget child;

  const BasicCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 55,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(10)),
          child: child),
    );
  }
}
