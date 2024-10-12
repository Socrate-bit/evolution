import 'package:flutter/material.dart';

int compareTimeOfDay(TimeOfDay? a, TimeOfDay? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  if (a.hour < b.hour) return -1;
  if (a.hour > b.hour) return 1;
  if (a.minute < b.minute) return -1;
  if (a.minute > b.minute) return 1;
  return 0;
  }
