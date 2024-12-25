import 'package:flutter/material.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';

class MultipleTimeOfDay extends StatefulWidget {
  const MultipleTimeOfDay({super.key});

  @override
  _MultipleTimeOfDayState createState() => _MultipleTimeOfDayState();
}

class _MultipleTimeOfDayState extends State<MultipleTimeOfDay> {
  final Map<String, TimeOfDay?> _selectedTimes = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
    'Sunday': null,
  };

  Future<void> _selectTime(BuildContext context, String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[day] ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTimes[day]) {
      setState(() {
        _selectedTimes[day] = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomModalBottomSheet(
      title: 'Select Time for Each Day',
      content: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
        ),
        itemCount: _selectedTimes.keys.length,
        itemBuilder: (context, index) {
          String day = _selectedTimes.keys.elementAt(index);
          return ListTile(
            title: Text(day),
            trailing: Text(
              _selectedTimes[day]?.format(context) ?? 'Select Time',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
            onTap: () => _selectTime(context, day),
          );
        },
      ),
    );
  }
}