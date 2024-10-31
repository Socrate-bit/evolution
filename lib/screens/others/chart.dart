import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/models/utilities/round_num.dart';

final _formater = DateFormat('MM/dd');

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2(this.data, this.pageIndex, {super.key});
  final List<(DateTime, double?)> data;
  final int pageIndex;

  @override
  State<LineChartSample2> createState() => _LineChartSample2State();
}

class _LineChartSample2State extends State<LineChartSample2> {
  late List<FlSpot> spots;
  late double maxX;
  List<Color> gradientColors = [
    Color(0xFF50E4FF),
    Colors.blue,
  ];

  @override
  void initState() {
    // TODO: implement initState
    spots = createSpot();
    maxX = spots.fold(0, (tot, b) => tot > b.x ? tot : b.x);
  }

  @override
  void didUpdateWidget(covariant LineChartSample2 oldWidget) {
    super.didUpdateWidget(oldWidget); // Call to super is recommended

    setState(() {
      spots = createSpot();
      maxX = spots.fold(0, (tot, b) => tot > b.x ? tot : b.x);
      switch (widget.pageIndex) {
        case 0:
          gradientColors = [
            Color(0xFF50E4FF),
            Colors.blue,
          ];
          break;
        case 1:
          gradientColors = [
            Color(0xFF50E4FF),
            Colors.blue,
          ];
          break;
        case 2:
          gradientColors = [
            const Color.fromARGB(255, 238, 87, 0),
            Colors.orange,
          ];
          break;
      }
    });
  }

  bool showAvg = false;

  List<FlSpot> createSpot() {
    List<FlSpot> spots = [];
    bool dataStart = false;
    int indexShift = 0;

    for (int index = 0; index < widget.data.length; index++) {
      if (widget.data[index].$2 == null) {
        if (dataStart == false) {
          indexShift += 1;
        } else {}
        continue;
      } else {
        dataStart = true;
        spots.add(FlSpot(index.toDouble() - indexShift,
            widget.data[index].$2!.customRound(1)));
      }
    }

    if (spots.length == 1) {
      double y = spots[0].y;
      spots[0] = FlSpot(1, y);
    }

    return spots;
  }

  double getMaxY() {
    double maxY;
    switch (widget.pageIndex) {
      case 0:
        maxY = 10;
      case 1:
        maxY = 100;
      case 2:
        maxY = widget.data.map((e) => e.$2).reduce(
                (a, b) => (a ?? 12) > (b ?? 12) ? (a ?? 12) : (b ?? 12))!;
        maxY *= 1.5;
      default:
        maxY = 10;
    }
    return maxY;
  }

  @override
  Widget build(BuildContext context) {
    return spots.isNotEmpty
        ? Stack(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1.70,
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 18,
                    left: 12,
                    top: 24,
                    bottom: 12,
                  ),
                  child: LineChart(
                    showAvg ? avgData() : mainData(),
                  ),
                ),
              ),
              // SizedBox(
              //   width: 60,
              //   height: 34,
              //   child: TextButton(
              //     onPressed: () {
              //       setState(() {
              //         showAvg = !showAvg;
              //       });
              //     },
              //     child: Text(
              //       'avg',
              //       style: TextStyle(
              //         fontSize: 12,
              //         color: showAvg ? Colors.white.withOpacity(0.5) : Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          )
        : const SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: 200,
              ),
              Text('No stats yet')
            ]));
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    double fontSize = 18;
    if (maxX == 1) {
      fontSize = 18;
    } else if (maxX < 3) {
      fontSize = 16;
    } else if (maxX < 6) {
      fontSize = 14;
    } else if (maxX < 9) {
      fontSize = 14;
    } else if (maxX < 12) {
      fontSize = 14;
    }

    final style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: fontSize, color: Colors.grey);
    String? text;
    List<DateTime> dates =
        widget.data.where((e) => e.$2 != null).map((e) => e.$1).toList();
    switch (value) {
      case 0:
        text = spots.length == 1 ? '' : _formater.format(dates[0]);
        break;
      case 1:
        text = spots.length >7 ? '' : spots.length == 1
            ? _formater.format(dates[0])
            : _formater.format(dates[1]);
        break;
      case 2:
        text = spots.length == 1 ? '' : _formater.format(dates[2]);
        break;
      case 3:
        text = spots.length >7 ? '' : _formater.format(dates[3]);
        break;
      case 4:
        text = _formater.format(dates[4]);
        break;
      case 5:
        text = spots.length >7 ? '' : _formater.format(dates[5]);
        break;
      case 6:
        text = _formater.format(dates[6]);
        break;
      case 7:
        text = spots.length >7 ? '' :_formater.format(dates[7]);
        break;
      case 8:
        text = _formater.format(dates[8]);
        break;
      case 9:
        text = spots.length >7 ? '' :_formater.format(dates[9]);
        break;
      case 10:
        text = _formater.format(dates[10]);
        break;
      case 11:
        text = spots.length >7 ? '' : _formater.format(dates[11]);
        break;
      default:
        text = 'Invalid index';
    }

    return text == null
        ? Container()
        : Text(text, style: style, textAlign: TextAlign.center);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    double maxY = getMaxY();
    const style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey);
    String? text;
    if (value == (maxY * 0.2).round()) {
      text = (maxY * 0.2).toInt().toString();
    } else if (value == (maxY * 0.5).round()) {
      text = (maxY * 0.5).toInt().toString();
    } else if (value == (maxY * 0.8).round()) {
      text = (maxY * 0.8).toInt().toString();
    }

    return text == null
        ? Container()
        : Text(text, style: style, textAlign: TextAlign.center);
  }

  LineChartData mainData() {
    return LineChartData(
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
            y: spots.last.y,
            strokeWidth: 1,
            color: Color(0xFF2196F3),
            dashArray: [2, 2],
            gradient: LinearGradient(
              colors: gradientColors,
            )),
      ]),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1 * getMaxY() / 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: spots.length == 1 ? 2 : maxX,
      minY: 0,
      maxY: getMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  LineChartData avgData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: bottomTitleWidgets,
            interval: 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
            interval: 1,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 2,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 3.44),
            FlSpot(2.6, 3.44),
            FlSpot(4.9, 3.44),
            FlSpot(6.8, 3.44),
            FlSpot(8, 3.44),
            FlSpot(9.5, 3.44),
            FlSpot(11, 3.44),
          ],
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
