import 'package:flutter/material.dart';
import 'package:tracker_v1/models/utilities/Scores/rating_utility.dart';

class CustomSlider extends StatefulWidget {
  const CustomSlider(
      {required this.initialValue,
      required this.onChanged,
      required this.toolTipTitle,
      required this.tooltipContent,
      super.key});

  final double initialValue;
  final void Function(double value) onChanged;
  final String toolTipTitle;
  final String tooltipContent;

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late double controlledValue;

  @override
  void initState() {
    super.initState();
    controlledValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            widget.toolTipTitle, textAlign: TextAlign.start, style: Theme.of(context).textTheme.titleSmall),
        Slider(
          activeColor: RatingUtility.getRatingColor(controlledValue),
          inactiveColor: Theme.of(context).colorScheme.surfaceBright,
          value: controlledValue,
          min: 0,
          max: 5,
          divisions: 4,
          label: RatingUtility.ratingText[controlledValue],
          onChanged: (value) {
            setState(() {
              controlledValue = value;
            });
            widget.onChanged(value);
          },
        ),
      ],
    );
  }
}
