import 'package:flutter/material.dart';
import 'package:tracker_v1/new_habit/display/circleday_widget.dart';
import 'package:tracker_v1/global/logic/day_of_the_week_utility.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';

class FrequencyPicker extends StatefulWidget {
  FrequencyPicker(
      {required this.passFrequency, required this.enteredWeekdays, super.key});

  final Function(int value) passFrequency;
  final List<WeekDay> enteredWeekdays;

  @override
  State<FrequencyPicker> createState() => _FrequencyPickerState();
}

class _FrequencyPickerState extends State<FrequencyPicker> {
  bool _frequencyType = false;
  int? _enteredFrequency;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CustomToolTipTitle(title: 'Frequency: ', content: 'Frequency'),
        const SizedBox(height: 8,),
        // SwitchListTile(
        //     subtitle: Text(_frequencyType
        //         ? 'Switch to specific days:'
        //         : 'Switch to random days:'),
        //     title: const CustomToolTipTitle(title: 'Frequency', content: 'Choose the frequency',),
        //     value: _frequencyType,
        //     onChanged: (value) {
        //       setState(() {
        //         _frequencyType = value;
        //       });
        //     }),
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
                        '$item time${item > 1 ? 's' : ''} per week',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _enteredFrequency = value;
                });
                widget.passFrequency(value);
              },
            ),
          )
        else
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ...WeekDay.values.expand(
              (item) {
                return [
                  CircleToggleDay(widget.enteredWeekdays, item),
                  const SizedBox(width: 10)
                ];
              },
            ),
          ]),
      ],
    );
  }
}
