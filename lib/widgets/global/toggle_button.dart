import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {

  const CustomToggleButton(
      {required this.pageNames,
      required this.selected,
      required this.onPressed,
      super.key});

  final List<String> pageNames;
  final int selected;
  final Function(int) onPressed;

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
        constraints: const BoxConstraints(
          minHeight: 20, // Minimum height for the buttons
          minWidth: 64, // Minimum width for the buttons
        ),
        isSelected: List.generate(pageNames.length, (index) => index == selected),
        fillColor: Colors.grey.withOpacity(0.5),
        onPressed: (index) {
          onPressed(index);
        },
        children: List.generate(pageNames.length, (index) {
          return Container(
            width: 72,
            height: 20,
            alignment: Alignment.center,
            child: Text(
              pageNames[index],
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }));
  }
}
