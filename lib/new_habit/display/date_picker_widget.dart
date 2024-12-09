import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _formater = DateFormat.yMd();

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget(
      {required this.passStartDate,
      required this.passEndDate,
      this.startDate,
      this.endDate,
      this.unique = false,
      super.key});

  final void Function(DateTime value) passStartDate;
  final void Function(DateTime value) passEndDate;
  final bool unique;
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    bool locked = false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedButton(
            locked: locked,
            widget.passStartDate,
            widget.startDate != null
                ? _formater.format(widget.startDate!).toString()
                : 'Start date', initialValue: widget.startDate,),
        if (!widget.unique)
        const SizedBox(
          width: 16,
        ),
        if (!widget.unique)
        RoundedButton(
          widget.passEndDate,
          widget.endDate != null
              ? _formater.format(widget.endDate!).toString()
              : 'End date', initialValue: widget.endDate,
        ),
      ],
    );
  }
}

class RoundedButton extends StatefulWidget {
  const RoundedButton(this.passDate, this.initialText,
      {super.key, this.locked = false, this.initialValue});

  final void Function(DateTime value) passDate;
  final String initialText;
  final bool locked;
  final DateTime? initialValue;

  @override
  State<RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  final DateTime _today = DateTime.now();
  DateTime? _enteredDate;

  Future<void> _datePicker() async {
    DateTime initial = widget.initialValue ?? _today;

    DateTime firstDate = DateTime(initial.year - 1, initial.month, initial.day);
    DateTime lastDate = DateTime(initial.year + 1, initial.month, initial.day);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initial,
    );

    if (pickedDate != null) {
      setState(() {
        _enteredDate = pickedDate;
      });
      widget.passDate(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.locked ? null : _datePicker,
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Theme.of(context).colorScheme.surfaceBright),
      child: Text(
        _enteredDate == null
            ? widget.initialText
            : _formater.format(_enteredDate!).toString(),
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
