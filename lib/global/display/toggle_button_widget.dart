import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {
  CustomToggleButton({
    required this.pageNames,
    required this.selected,
    required this.onPressed,
    this.color,
    super.key,
  });

  final List<String> pageNames;
  final int selected;
  final Function(int) onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonWidth = constraints.maxWidth / pageNames.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: buttonWidth * selected,
                child: Container(
                  width: buttonWidth,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Row(
                children: List.generate(pageNames.length, (index) {
                  return GestureDetector(
                    onTap: () => onPressed(index),
                    child: Container(
                      height: 40,
                      width: buttonWidth,
                      alignment: Alignment.center,
                      child: Text(
                        pageNames[index],
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight:
                                selected == index ? FontWeight.bold : null,
                            color:
                                selected == index ? Colors.white : Colors.grey),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
