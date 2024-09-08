import 'package:flutter/material.dart';
import 'package:tracker_v1/widgets/recaps/custom_tool_tip_title.dart';

class BigTextFormField extends StatelessWidget {
  const BigTextFormField(
      {required this.controlledValue,
      required this.onSaved,
      required this.toolTipTitle,
      required this.tooltipContent,
      super.key});

  final String? controlledValue;
  final void Function(String? value) onSaved;
  final String toolTipTitle;
  final String tooltipContent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomToolTipTitle(title: toolTipTitle, content: tooltipContent),
        TextFormField(
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (value) {
            FocusScope.of(context).unfocus();
          },
          initialValue: controlledValue,
          minLines: 3,
          maxLines: 3,
          validator: (value) {
            return null;
          },
          onSaved: (value) {
            onSaved(value);
          },
          maxLength: 1000,
          style: Theme.of(context)
              .textTheme
              .bodyMedium,
          decoration: InputDecoration(
            filled: true,
            fillColor:
                Theme.of(context).colorScheme.surfaceBright.withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 8)
      ],
    );
  }
}
