import 'package:flutter/material.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';

class BigTextFormField extends StatelessWidget {
  const BigTextFormField(
      {required this.controlledValue,
      required this.onSaved,
      required this.toolTipTitle,
      required this.tooltipContent,
      this.maxLine = 3,
      this.maxLenght = 1000,
      super.key});

  final String? controlledValue;
  final void Function(String? value) onSaved;
  final String toolTipTitle;
  final String tooltipContent;
  final int maxLine;
  final int maxLenght;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomToolTipTitle(title: toolTipTitle, content: tooltipContent),
        TextFormField(
          textInputAction: TextInputAction.newline,
          onFieldSubmitted: (value) {
            FocusScope.of(context).unfocus();
          },
          initialValue: controlledValue,
          minLines: maxLine,
          maxLines: maxLine + 20,
          validator: (value) {
            return null;
          },
          onSaved: (value) {
            onSaved(value);
          },
          maxLength: maxLenght,
          style: Theme.of(context).textTheme.bodyMedium,
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
