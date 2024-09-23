import 'package:flutter/material.dart';

class RatingUtility {
  static final Map<double, String> ratingText = {
    0: 'Awful',
    1.25: 'Poor',
    2.5: 'Okay',
    3.75: 'Good',
    5: 'Perfect'
  };

  static Color getRatingColor(double value) {
    if (value < 1) return Colors.red;
    if (value < 2.5) return Colors.orange;
    if (value < 3.75) return const Color.fromARGB(255, 248, 189, 51); 
    if (value < 5) return Colors.green;
    if (value == 5) return Colors.blue;
    return Colors.grey;
    
  }
}