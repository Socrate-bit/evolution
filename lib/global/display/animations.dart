import 'package:flutter/material.dart';

class SwitcherAnimation extends StatelessWidget {
  const SwitcherAnimation(this.child, {super.key});
  final dynamic child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        transitionBuilder: (switcherChild, animation) {
          return SizeTransition(
            sizeFactor: animation,
            child: FadeTransition(
              opacity: animation,
              child: switcherChild,
            ),
          );
        },
        duration: Duration(milliseconds: 300),
        child: child);
  }
}
