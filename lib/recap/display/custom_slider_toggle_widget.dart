import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_v1/global/logic/rating_display_utility.dart';

class CustomToggleButtonsSlider extends StatefulWidget {
  const CustomToggleButtonsSlider({
    required this.initialValue,
    required this.onChanged,
    required this.toolTipTitle,
    required this.tooltipContent,
    super.key,
  });

  final double initialValue;
  final void Function(double value) onChanged;
  final String toolTipTitle;
  final String tooltipContent;

  @override
  State<CustomToggleButtonsSlider> createState() =>
      _CustomToggleButtonsSliderState();
}

class _CustomToggleButtonsSliderState extends State<CustomToggleButtonsSlider> {
  late double controlledValue; // We'll use integers to represent button index

  @override
  void initState() {
    super.initState();
    controlledValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    List<double> ratingKeys = RatingDisplayUtility.ratingText.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.toolTipTitle,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 10),
        Center(
          child: ToggleButtons(
            borderRadius: BorderRadius.horizontal(
              left: const Radius.circular(10) ,
              right: const Radius.circular(10) ,
            ),
            constraints: const BoxConstraints(
              minHeight: 20, // Minimum height for the buttons
              minWidth: 50, // Minimum width for the buttons
            ),
            isSelected: List.generate(
                5, (index) => index == ratingKeys.indexOf(controlledValue)),
            fillColor: RatingDisplayUtility.ratingToColor(
                controlledValue.toDouble()), // Color for unselected
            onPressed: (index) {
              HapticFeedback.selectionClick();
              setState(() {
                controlledValue = ratingKeys[index];
              });
              widget.onChanged(
                  ratingKeys[index]); // Call onChanged with double value
            },
            children: List.generate(5, (index) {
              return Container(
                decoration: BoxDecoration(
                  color: controlledValue > index + 1
                      ? RatingDisplayUtility.ratingToColor(
                          controlledValue.toDouble())
                      : null,
                ),
                width: 64, // Set a custom width
                height: 20, // Set a custom height (less height)
                alignment: Alignment.center, // Center the text inside
                child: Text(
                  RatingDisplayUtility.ratingText.values
                      .toList()[index], // Button labels as 1 to 5
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: controlledValue > index + 1
                          ? RatingDisplayUtility.ratingToColor(
                              controlledValue.toDouble())
                          : Theme.of(context).colorScheme.background,
                      fontWeight: FontWeight.bold),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
