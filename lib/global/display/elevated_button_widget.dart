import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    this.color,
    required this.submit,
    this.text = 'Submit',
    super.key,
  });

  final void Function() submit;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            submit();
          },
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Theme.of(context).colorScheme.surface),
          ),
        ),
      ),
    );
  }
}
