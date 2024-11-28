import 'package:fl_chart/fl_chart.dart';
import 'basic_computation_utility.dart';

class ChartData {
  late double maxX, minX, maxY;
  late List<FlSpot> mainCurveSpots;
  late List<FlSpot>? secondaryCurveSpots;

  ChartData({
    required List<(DateTime, double?)> data,
    List<(DateTime, double?)>? data2,
    double? maxAxe,
  }) {
    // Generate the curve spots
    mainCurveSpots = _generateCurveSpots(data);

    // Compute the min and max values for the axes
    _computeMaxMinAxes();

    if (data2 != null && mainCurveSpots.isNotEmpty) {
      secondaryCurveSpots =
          _generateSecondaryCurveSpots(data, data2, minX, maxX);
    } else {
      secondaryCurveSpots = null;
    }
  }

  List<FlSpot> _generateCurveSpots(List<(DateTime, double?)> data) {
    List<FlSpot> generatedSpots = [];

    for (int index = 0; index < data.length; index++) {
      bool isDataNull = data[index].$2 == null;
      if (isDataNull) {
        continue;
      }

      double x = index.toDouble();
      double y = data[index].$2!;
      generatedSpots.add(FlSpot(x, y));
    }

    return generatedSpots;
  }

  void _computeMaxMinAxes() {
    if (mainCurveSpots.isEmpty) {
      maxX = 0;
      minX = 0;
      maxY = 0;
      return;
    }
    maxX = computeMaxList(mainCurveSpots.map((e) => e.x).toList())!;
    minX = computeMinList(mainCurveSpots.map((e) => e.x).toList())!;
    maxY = computeMaxList(mainCurveSpots.map((e) => e.y).toList())! * 1.5;
    if (maxY == 0) maxY = 10;
    if (mainCurveSpots.length == 1) {
      minX -= 1;
      maxX += 1;
    }
  }

  double? getXLenght() {
    return maxX - minX;
  }

  List<FlSpot> _generateSecondaryCurveSpots(List<(DateTime, double?)> data,
      List<(DateTime, double?)> data2, double minX, double maxX) {
    List<FlSpot> generatedSpots = [];

    if (data2.where((e) => e.$2 != null).isEmpty) {
      return generatedSpots;
    }

    List<(DateTime, double?)> normalizedData = _rangeNormalization(data2, data);
    generatedSpots = _generateCurveSpots(normalizedData);

    generatedSpots =
        generatedSpots.where((e) => e.x <= maxX && e.x >= minX).toList();

    return generatedSpots;
  }

  List<(DateTime, double?)> _meanNormalization(
      List<(DateTime, double?)> data1, List<(DateTime, double?)> data2) {
    double mean1 = computeMeanList(data1.map((e) => e.$2).toList())!;
    double mean2 = computeMeanList(data2.map((e) => e.$2).toList())!;
    double shift = mean1 - mean2;
    List<(DateTime, double?)> shiftedData =
        data1.map((e) => (e.$1, e.$2 == null ? e.$2 : e.$2! - shift)).toList();
    return shiftedData;
  }

  List<(DateTime, double?)> _rangeNormalization(
      List<(DateTime, double?)> secondaryData,
      List<(DateTime, double?)> mainData) {
    // Filter out null values for computation
    List<double> values1 =
        secondaryData.map((e) => e.$2).whereType<double>().toList();
    List<double> values2 =
        mainData.map((e) => e.$2).whereType<double>().toList();


    // Compute min and max values correctly
    double minSecondary = computeMinList(values1)!;
    double maxSecondary = computeMaxList(values1)!;
    double minMain = computeMinList(values2)!;
    double maxMain = computeMaxList(values2)!;

    // Compute ranges
    double rangeSecondary = maxSecondary - minSecondary;
    double rangeMain = maxMain - minMain;

    // Avoid division by zero
    if (rangeSecondary == 0) {
      return _meanNormalization(secondaryData, mainData);
    }

    // Avoid flat curve
    double shift = 0;
    if (rangeMain == 0) {
      shift = minMain * 0.25;
      minMain = maxMain * 0.25;
      rangeMain = maxMain - minMain;
    }

    // Shift and scale data1
    List<(DateTime, double?)> shiftedData = secondaryData.map((e) {
      if (e.$2 == null) return e;
      return (
        e.$1,
        ((e.$2! - minSecondary) / rangeSecondary) * rangeMain + minMain + (shift),
      );
    }).toList();

    return shiftedData;
  }
}
