import 'package:flutter/material.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';

class BigTextFormField extends StatefulWidget {
  const BigTextFormField(
      {required this.controlledValue,
      required this.onSaved,
      required this.toolTipTitle,
      required this.tooltipContent,
      this.minLine = 3,
      this.maxLine = 20,
      this.maxLenght = 1000,
      this.color,
      super.key});

  final String controlledValue;
  final void Function(String? value) onSaved;
  final String toolTipTitle;
  final String tooltipContent;
  final int maxLine;
  final int minLine;
  final int maxLenght;
  final Color? color;

  @override
  State<BigTextFormField> createState() => _BigTextFormFieldState();
}

class _BigTextFormFieldState extends State<BigTextFormField> {
  late final TextEditingController controller;
  late final FocusNode focusNode;

  @override
  void initState() {
    controller = TextEditingController(text: widget.controlledValue);
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BigTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.text = widget.controlledValue;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomToolTipTitle(
            title: widget.toolTipTitle, content: widget.tooltipContent),
        TextFormField(
          textInputAction: TextInputAction.newline,
          onFieldSubmitted: (value) {
            FocusScope.of(context).unfocus();
          },
          controller: controller,
          focusNode: focusNode,
          minLines: widget.minLine,
          maxLines: widget.maxLine,
          validator: (value) {
            return null;
          },
          onSaved: (value) {
            widget.onSaved(value);
          },
          onTapOutside: (event) {
            widget.onSaved(controller.text);
          },
          onEditingComplete: () {
            widget.onSaved(controller.text);
          },
          maxLength: widget.maxLenght,
          style: Theme.of(context).textTheme.bodyMedium,
          cursorColor: widget.color ?? Theme.of(context).primaryColor,
          decoration: InputDecoration(
            filled: true,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: widget.color ?? Theme.of(context).primaryColor,
                  width: 3),
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
