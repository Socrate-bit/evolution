import 'package:flutter/material.dart';

class RatingUtility {
  static final Map<double, String> ratingText = {
    0: 'Awful',
    1.25: 'Poor',
    2.5: 'Okay',
    3.75: 'Good',
    5: 'Perfect'
  };

  static Color getRatingColor(double? value) {
    if (value == null) return Colors.blue;
    if (value < 1.25) return Colors.red;
    if (value == 1.25) return Colors.orange;
    if (value <= 2.5) return const Color.fromARGB(255, 248, 189, 51);
    if (value <= 3.75) return Colors.green; 
    if (value <= 5) return Colors.blue;
    if (value > 5) return Colors.purple;
    return Colors.grey;
    
  }

    static int getRatingNumber(double? value) {
    if (value == null) return 5;
    if (value < 1.25) return 0;
    if (value == 1.25) return 1;
    if (value < 2.5) return 2;
    if (value < 3.75) return 3; 
    if (value < 5) return 4;
    if (value == 5) return 5;
    return 4;
    
  }
}