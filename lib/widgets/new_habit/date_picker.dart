import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget(
      {required this.passStartDate, required this.passEndDate, super.key});

  final void Function(DateTime value) passStartDate;
  final void Function(DateTime value) passEndDate;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundedButton(widget.passStartDate, 'Start date'),
        const SizedBox(width: 16,),
        RoundedButton(widget.passEndDate, 'End date'),
      ],
    );
  }
}

class RoundedButton extends StatefulWidget {
  const RoundedButton(this.passDate, this.initialValue, {super.key});

  final void Function(DateTime value) passDate;
  final String initialValue;

  @override
  State<RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<RoundedButton> {
  final DateTime _today = DateTime.now();
  final _formater = DateFormat.yMd();
  DateTime? _enteredDate;

 Future<void> _datePicker() async {
    DateTime lastDate = DateTime(_today.year + 1, _today.month, _today.day);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: _today,
      lastDate: lastDate,
      initialDate: _today,
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
      onPressed: _datePicker
      ,
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Theme.of(context).colorScheme.surfaceBright), 
          
      child: Text(
        _enteredDate == null
            ? widget.initialValue
            : _formater.format(_enteredDate!).toString(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
