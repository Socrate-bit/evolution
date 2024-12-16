import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String? title;
  final Widget? child;

  const CustomContainer({super.key, this.title, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surfaceBright),
        child: Column(
          children: [
            if (title != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title!,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            if (child != null) child!
          ],
        ));
  }
}