import 'package:flutter/material.dart';

class BasicTextFormField extends StatelessWidget {
  const BasicTextFormField({
    super.key,
    required this.maxLength,
    required this.label,
    this.wrongEntryMessage = 'Wrong entry',
    this.optional = true,
    this.controller,
    required this.passValue,
    this.initialValue,
  });

  final int maxLength;
  final String label;
  final String wrongEntryMessage;
  final bool optional;
  final void Function(String? enteredValue) passValue;
  final TextEditingController? controller;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      validator: (value) {
        if (!optional && (value == null || value.trim().isEmpty)) {
          return wrongEntryMessage;
        }
        return null;
      },
      onSaved: (value) {
        passValue(value);
      },
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) {
        FocusScope.of(context).unfocus();
      },
      style: Theme.of(context).textTheme.bodyMedium,
      maxLength: maxLength,
      decoration: InputDecoration(
        filled: true,
        fillColor:
            Theme.of(context).colorScheme.surfaceBright.withOpacity(0.75),
        label: Text(label),
      ),
    );
  }
}
