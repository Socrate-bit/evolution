import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    required this.submit,
    this.text = 'Submit',
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
        child: OutlinedButton(
          onPressed: submit,
          style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              foregroundColor: Theme.of(context).colorScheme.primary),
          child: Text(text,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent.withOpacity(0.5))),
        ),
      ),
    );
  }
}
