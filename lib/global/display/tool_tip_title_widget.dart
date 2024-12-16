import 'package:flutter/material.dart';

class CustomToolTipTitle extends StatelessWidget {
  const CustomToolTipTitle({
    required this.title,
    required this.content,
    super.key,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .titleMedium!.copyWith(color: Colors.white.withOpacity(0.75))),
        const SizedBox(
          width: 8,
        ),
        Tooltip(
          waitDuration: const Duration(milliseconds: 1),
          message: content,
          child: Icon(
            Icons.info_outline_rounded,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
            size: 20,
          ),
        )
      ],
    );
  }
}
