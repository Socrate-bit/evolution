import 'package:flutter/material.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';

class BigTextFormField extends StatelessWidget {
  BigTextFormField(
      {required this.controlledValue,
      required this.onSaved,
      required this.toolTipTitle,
      required this.tooltipContent,
      this.maxLine = 3,
      this.maxLenght = 1000,
      this.color,
      super.key});

  final String? controlledValue;
  final void Function(String? value) onSaved;
  final String toolTipTitle;
  final String tooltipContent;
  final int maxLine;
  final int maxLenght;
  final Color? color;
  late final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    controller = TextEditingController(text: controlledValue);

    return Column(
      children: [
        CustomToolTipTitle(title: toolTipTitle, content: tooltipContent),
        TextFormField(
          textInputAction: TextInputAction.newline,
          onFieldSubmitted: (value) {
            FocusScope.of(context).unfocus();
          },
          controller: controller,
          minLines: maxLine,
          maxLines: maxLine + 20,
          validator: (value) {
            return null;
          },
          onSaved: (value) {
            onSaved(value);
          },
          onTapOutside: (event) {
            onSaved(controller.text);
          },
          onEditingComplete: () {
            onSaved(controller.text);
          },
          maxLength: maxLenght,
          style: Theme.of(context).textTheme.bodyMedium,
          cursorColor: color,
          decoration: InputDecoration(
            filled: true,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: color ?? Theme.of(context).primaryColor, width: 3),
            ),
            fillColor:
                Theme.of(context).colorScheme.surfaceBright.withOpacity(0.75),
          ),
        ),
        const SizedBox(height: 8)
      ],
    );
  }
}
