import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticTestPage extends StatelessWidget {
  void _triggerHapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.lightImpact:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.mediumImpact:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavyImpact:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selectionClick:
        HapticFeedback.selectionClick();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () =>
                _triggerHapticFeedback(HapticFeedbackType.lightImpact),
            child: Text('Light Impact'),
          ),
          ElevatedButton(
            onPressed: () =>
                _triggerHapticFeedback(HapticFeedbackType.mediumImpact),
            child: Text('Medium Impact'),
          ),
          ElevatedButton(
            onPressed: () =>
                _triggerHapticFeedback(HapticFeedbackType.heavyImpact),
            child: Text('Heavy Impact'),
          ),
          ElevatedButton(
            onPressed: () =>
                _triggerHapticFeedback(HapticFeedbackType.selectionClick),
            child: Text('Selection Click'),
          ),
          ElevatedButton(
            onPressed: () => _triggerHapticFeedback(HapticFeedbackType.vibrate),
            child: Text('Vibrate'),
          ),
          ElevatedButton(
            onPressed: () async {
              const int amplitude = 128; // Range: 1-255
              await Vibration.vibrate(duration: 10, amplitude: amplitude);
            },
            child: Text('Plugin Vibration'),
          ),
          ElevatedButton(
            onPressed: () async {
              const int amplitude = 128; // Range: 1-255
              await Vibration.vibrate(
                  duration: 10,
                  amplitude: amplitude,
                  pattern: [500, 1000, 500, 2000],
                  intensities: [1, 255]);
            },
            child: Text('Plugin Vibration'),
          ),
        ],
      ),
    );
  }
}

enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}
