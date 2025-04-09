import 'package:flutter/services.dart';
import 'package:tracker_v1/effects/effects_service.dart';
import 'package:tracker_v1/recap/data/habit_recap_model.dart';

void validationHaptic(HabitRecap newTrackedDay, HabitRecap? oldTrackedDay) {
  if (oldTrackedDay?.done != Validated.yes &&
      newTrackedDay.done == Validated.yes) {
    EffectsService().playValidated();
    HapticFeedback.heavyImpact();
  } else if (oldTrackedDay?.done != Validated.no &&
      newTrackedDay.done == Validated.no) {
    EffectsService().playFaillure();
    HapticFeedback.heavyImpact();
  } else if (oldTrackedDay?.done != Validated.notYet &&
      newTrackedDay.done == Validated.notYet) {
    EffectsService().playUnvalided();
    HapticFeedback.lightImpact();
  } else {
    HapticFeedback.lightImpact();
  }
}
