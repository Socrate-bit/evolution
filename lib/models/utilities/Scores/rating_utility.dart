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
    if (value < 1) return Colors.red;
    if (value < 2) return Colors.orange;
    if (value < 3) return const Color.fromARGB(255, 248, 189, 51);
    if (value < 4) return Colors.green; 
    if (value <= 5) return Colors.blue;
    return const Color.fromARGB(255, 52, 52, 52);
    
  }

    static int getRatingNumber(double? value) {
    if (value == null) return 6;
    if (value < 1) return 2;
    if (value < 2) return 3;
    if (value < 3) return 4;
    if (value < 4) return 5; 
    if (value <= 5) return 6;
    return 6;
    
  }
}