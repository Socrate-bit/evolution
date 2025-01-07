import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomToggleButton extends StatelessWidget {
  const CustomToggleButton({
    required this.pageNames,
    required this.selected,
    required this.onPressed,
    this.fillLower = false,
    this.color,
    this.selectedTest,
    super.key,
  });

  final List<String> pageNames;
  final int selected;
  final Function(int) onPressed;
  final Color? color;
  final bool fillLower;
  final String? selectedTest;

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
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onPressed(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                          left: index == 0 ? Radius.circular(10) : Radius.zero,
                          right: index == selected
                              ? Radius.circular(10)
                              : Radius.zero,
                        ),
                        color: fillLower && index <= selected
                            ? color?.withOpacity(0.25) ??
                                Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.25)
                            : Colors.transparent,
                      ),
                      height: 40,
                      width: buttonWidth,
                      alignment: Alignment.center,
                      child: Text(
                        (selectedTest != null && index == selected)
                            ? selectedTest!
                            : pageNames[index],
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
