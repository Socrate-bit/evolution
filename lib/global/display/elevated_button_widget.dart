import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    required this.submit,
    this.text= 'Submit',
    super.key,
  });

  final void Function() submit;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: submit,
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .titleMedium!.copyWith(color: Theme.of(context).colorScheme.surface),
          ),
        ),
      ),
    );
  }
}