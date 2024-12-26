import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/new_habit/data/frequency_state.dart';
import 'package:tracker_v1/new_habit/data/schedule_model.dart';

class StartEndDateBottom extends ConsumerWidget {
  const StartEndDateBottom({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomModalBottomSheet(
      content: Column(
        children: [
          DatePickerWidget(isStartDate: true),
          DatePickerWidget(isStartDate: false),
        ],
      ),
    );
  }
}

class DatePickerWidget extends ConsumerStatefulWidget {
  const DatePickerWidget({required this.isStartDate, super.key});
  final bool isStartDate;

  @override
  ConsumerState<DatePickerWidget> createState() => _DatePickerState();
}

class _DatePickerState extends ConsumerState<DatePickerWidget> {
  DateTime? date;
  late String displayedDate;
  late bool checkBoxValue;

  void _initWidgetState() {
    // Load dates
    Schedule frequencyState = ref.watch(frequencyStateProvider);

    if (widget.isStartDate) {
      if (frequencyState.startDate != null) {
        date = frequencyState.startDate!;
      } else {
        date = date ?? today;
      }
      // If start date is after end date
      if (frequencyState.endingDate != null &&
          date!.isAfter(ref.read(frequencyStateProvider).endingDate!)) {
        date = frequencyState.endingDate;
      }
    } else {
      if (frequencyState.startDate != null) {
        date = frequencyState.endingDate ??
            frequencyState.startDate!.add(Duration(days: 30));
      } else {
        date = date ?? today.add(Duration(days: 30));
      }
    }

    // Init checkbox
    checkBoxValue = widget.isStartDate
        ? frequencyState.startDate != null
        : frequencyState.endingDate != null;

    // Generate displayed date
    displayedDate = formater3.format(date!);
  }

  void _toggleActiveDate(bool? value) {
    if (widget.isStartDate) {
      ref
          .read(frequencyStateProvider.notifier)
          .setStartDate((value ?? true) ? date : null);
    } else {
      ref
          .read(frequencyStateProvider.notifier)
          .setEndingDate((value ?? true) ? date : null);
    }
  }

  void _pickDate() async {
    Schedule frequencyState = ref.watch(frequencyStateProvider);

    if (checkBoxValue) {
      // Pick the date
      date = await _datePicker(context, ref) ?? date;

      // Upload the date
      if (widget.isStartDate) {
        ref.read(frequencyStateProvider.notifier).setStartDate(date);

        // If start date is after end date
        if (frequencyState.endingDate != null &&
            date!.isAfter(ref.read(frequencyStateProvider).endingDate!)) {
          ref.read(frequencyStateProvider.notifier).setEndingDate(date);
        }
      } else {
        ref.read(frequencyStateProvider.notifier).setEndingDate(date);

        // If end date is before start date
        if (frequencyState.startDate != null &&
            date!.isBefore(ref.read(frequencyStateProvider).startDate!)) {
          ref.read(frequencyStateProvider.notifier).setStartDate(date);
        }
      }
    } else {
      return;
    }
  }

  Future<DateTime?> _datePicker(context, WidgetRef ref) async {
    DateTime initial = date!;

    DateTime firstDate = DateTime(initial.year - 1, initial.month, initial.day);
    DateTime lastDate = DateTime(initial.year + 1, initial.month, initial.day);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initial,
    );

    if (pickedDate != null) {
      return pickedDate;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _initWidgetState();

    return ListTile(
      title: Row(
        children: [
          Checkbox(value: checkBoxValue, onChanged: _toggleActiveDate),
          Text(widget.isStartDate ? 'Start' : 'End',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: checkBoxValue ? null : Colors.grey)),
        ],
      ),
      trailing: GestureDetector(
        onTap: _pickDate,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: checkBoxValue
                ? Theme.of(context).colorScheme.surfaceBright
                : null,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(displayedDate,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: checkBoxValue ? null : Colors.grey)),
        ),
      ),
    );
  }
}
