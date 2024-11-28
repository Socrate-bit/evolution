import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tracker_v1/models/utilities/round_num.dart';
import 'package:tracker_v1/statistic_screen/logics/chart_service.dart';
import 'package:tracker_v1/statistic_screen/logics/correlation_utility.dart';

class LineChartDisplay extends StatefulWidget {
  const LineChartDisplay(this.data, this.maxAxe,
      {super.key, this.data2, this.pageName});
  final List<(DateTime, double?)> data;
  final List<(DateTime, double?)>? data2;
  final double? maxAxe;
  final String? pageName;

  @override
  State<LineChartDisplay> createState() => _LineChartDisplayState();
}

class _LineChartDisplayState extends State<LineChartDisplay> {
  late ChartData _chartData;
  late double _lenghtX;
  static const List<Color> _gradientColors = [
    Color(0xFF50E4FF),
    Colors.blue,
  ];

  static const List<Color> _gradientColors2 = [
    const Color.fromARGB(255, 238, 87, 0),
    Colors.orange,
  ];

  @override
  void initState() {
    _chartData = ChartData(
        data: widget.data, data2: widget.data2, maxAxe: widget.maxAxe);
    _lenghtX = _chartData.getXLenght()!;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LineChartDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data || oldWidget.data2 != widget.data2) {
      setState(() {
        _chartData = ChartData(
            data: widget.data, data2: widget.data2, maxAxe: widget.maxAxe);
        _lenghtX = _chartData.getXLenght()!;
      });
    }
  }

  TextStyle _geTextStyle(double? correlation) {
    if (correlation == null) {
      return TextStyle(color: Colors.white);
    } else if (correlation > 0.75) {
      return TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold);
    } else if (correlation < -0.75) {
      return TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold);
      } else if (correlation > 0.5) {
        return TextStyle(color: Colors.green, fontWeight: FontWeight.bold);
      } else if (correlation < -0.5) {
        return TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold);
    } else {
      return TextStyle(color: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    double? correlation;

    // Compute correlation
    if (widget.data2 != null) {
      correlation = computeCorrelation(widget.data.map((e) => e.$2).toList(),
          widget.data2!.map((e) => e.$2).toList());
    }

    return _chartData.mainCurveSpots.isNotEmpty
        ? Stack(
            children: <Widget>[
              SizedBox(
                height: 220,
              ),
              if (correlation != null)
                RichText(
                  text: TextSpan(
                    text: 'Correlation: ',
                    style: TextStyle(color: Colors.white),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${correlation.customRound(2)}',
                        style: _geTextStyle(correlation),
                      ),
                    ],
                  ),
                ),
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
                    _generateMainChartData(),
                  ),
                ),
              ),
            ],
          )
        : const SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                height: 220,
              ),
              Text('No stats yet')
            ]));
  }

  LineChartData _generateMainChartData() {
    return LineChartData(
      extraLinesData: ExtraLinesData(horizontalLines: [
        _horizontalLine(),
      ]),
      gridData: _generateGrid(),
      titlesData: _generateTitle(),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: _chartData.minX,
      maxX: _chartData.maxX,
      minY: 0,
      maxY: _chartData.maxY,
      lineTouchData: _generateTouchData(),
      lineBarsData: [
        _generateCurve(_chartData.mainCurveSpots, true),
        if (_chartData.secondaryCurveSpots != null &&
            _chartData.secondaryCurveSpots!.isNotEmpty)
          _generateCurve(_chartData.secondaryCurveSpots!, false),
      ],
    );
  }

  Widget _generateXLabel(double value, TitleMeta meta) {
    double fontSize = 18;
    String? text;
    List<DateTime> dates = widget.data.map((e) => e.$1).toList();
    bool onlyOnePoint = _chartData.mainCurveSpots.length == 1;

    // Compute font size
    if (onlyOnePoint) {
      fontSize = 20;
    } else if (_chartData.mainCurveSpots.length == 2) {
      fontSize = 18;
    } else if (_lenghtX < 8) {
      fontSize = 16;
    } else {
      fontSize = 14;
    }

    final style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: fontSize, color: Colors.grey);

    // Compute if text visible or not
    if (onlyOnePoint && (value == 0 || value == 2)) {
      text = '';
    } else if (_lenghtX <= 12 && _lenghtX > 6 && value % 2 == 1) {
      text = '';
    } else if (_lenghtX > 12 && !((value) % (_lenghtX / 6).toInt() == 0)) {
      text = '';
    } else {
      if (widget.pageName == 'Monthly') {
        text = DateFormat('MMM')
            .format(dates[_chartData.minX.toInt() + value.toInt()]);
      } else {
        text = DateFormat('MM/dd')
            .format(dates[_chartData.minX.toInt() + value.toInt()]);
      }
    }

    return text.isEmpty
        ? Container()
        : Text(text, style: style, textAlign: TextAlign.center);
  }

  Widget _generateYLabel(double value, TitleMeta meta) {
    double maxY = _chartData.maxY;
    const style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey);
    String? text;
    if (value.customRound(1) == (maxY * 0.2).customRound(1)) {
      text = (maxY * 0.2).toInt().toString();
    } else if (value.customRound(1) == (maxY * 0.5).customRound(1)) {
      text = (maxY * 0.5).toInt().toString();
    } else if (value.customRound(1) == (maxY * 0.8).customRound(1)) {
      text = (maxY * 0.8).toInt().toString();
    }

    return text == null
        ? Container()
        : Text(text, style: style, textAlign: TextAlign.center);
  }

  LineChartBarData _generateCurve(List<FlSpot> spots, bool filledBellow) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      gradient: LinearGradient(
        colors: filledBellow ? _gradientColors : _gradientColors2,
      ),
      barWidth: filledBellow ? 5 : 3,
      dashArray: filledBellow ? null : [6, 6],
      isStrokeCapRound: true,
      dotData: const FlDotData(
        show: true,
      ),
      belowBarData: BarAreaData(
        show: filledBellow,
        gradient: LinearGradient(
          colors:
              _gradientColors.map((color) => color.withOpacity(0.3)).toList(),
        ),
      ),
    );
  }

  FlTitlesData _generateTitle() {
    return FlTitlesData(
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
          getTitlesWidget: (double double, TitleMeta titlemeta) {
            return _generateXLabel(double - _chartData.minX, titlemeta);
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 0.1,
          getTitlesWidget: _generateYLabel,
          reservedSize: 42,
        ),
      ),
    );
  }

  FlGridData _generateGrid() {
    return FlGridData(
      show: true,
      drawVerticalLine: true,
      horizontalInterval: 1 * _chartData.maxY / 10,
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
    );
  }

  LineTouchData _generateTouchData() {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            if (touchedSpot.barIndex == 0) {
              // Customize tooltip for the first curve
              return LineTooltipItem(
                '${touchedSpot.y.customRound(2)}',
                TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              );
            } else if (touchedSpot.barIndex == 1) {
              // Customize tooltip for the second curve
              return LineTooltipItem(
                '${widget.data2![touchedSpot.x.toInt()].$2?.customRound(2)}',
                TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              );
            }

            final flSpot = touchedSpot;
            return LineTooltipItem('${flSpot.y}', TextStyle());
          }).toList();
        },
      ),
    );
  }

  HorizontalLine _horizontalLine() {
    return HorizontalLine(
        y: _chartData.mainCurveSpots.last.y,
        strokeWidth: 1,
        color: Color(0xFF2196F3),
        dashArray: [2, 2],
        gradient: LinearGradient(
          colors: _gradientColors,
        ));
  }
}
