import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyWidget extends StatelessWidget {
  const MyWidget({super.key, this.function, this.color, required this.text});
  final Function? function;
  final Color? color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          if (function != null) {
            function!();
          }
        },
        child: Text(text,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                color: color ?? Theme.of(context).colorScheme.primary)));
  }
}
