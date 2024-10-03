import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/models/utilities/days_utility.dart';
import 'package:tracker_v1/models/utilities/rating_utility.dart';
import 'package:tracker_v1/models/utilities/score_computing.dart';
import 'package:tracker_v1/providers/habits_provider.dart';

class DaySwitch extends ConsumerStatefulWidget {
  final Function switchDay;
  final DateTime _selectedDay;

  const DaySwitch(this.switchDay, this._selectedDay, {super.key});

  @override
  ConsumerState<DaySwitch> createState() => _DaySwitchState();
}

class _DaySwitchState extends ConsumerState<DaySwitch> {
  final DateTime _now = DateTime.now();
  late DateTime _today;
  late DateTime _selectedDay;
  late PageController _pageController;
  int weekIndex = 0;

  List<DateTime> get _getOffsetWeekDays {
    DateTime now = DateTime.now();
    int weekShift = weekIndex * 7;
    return List.generate(
        7,
        (i) => DateTime(
            now.year, now.month, now.day - now.weekday + 1 + i + weekShift));
  }

  void _pickDay(pickedDay) {
    setState(() {
      _selectedDay = pickedDay;
    });
    widget.switchDay(pickedDay);
  }

  String _displayedScore(double score) {
    String displayedScore = '-';

    if (score == null || score.isNaN) {
      return displayedScore;
    }

    if (score == score.toInt()) {
      displayedScore = score.toInt().toString();
    } else {
      displayedScore = score.toStringAsFixed(2);
    }

    if (score > 10) {
      displayedScore += ' 🥇';
    } else if (score >= 7.5) {
      displayedScore += ' 🎉';
    }

    return displayedScore;
  }

  @override
  void initState() {
    _pageController = PageController(initialPage: 52);
    _selectedDay = widget._selectedDay;
    _today = DateTime(_now.year, _now.month, _now.day);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List score = scoreComputing(_selectedDay, ref);

    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).colorScheme.surface,
      height: 60,
      child: Row(
        children: [
          Container(
            width: 300,
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (ctx, item) {
                weekIndex = item - 52;
                final List<DateTime> dayList = _getOffsetWeekDays;
                bool previousScore = false;
                return ListView.builder(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (ctx, item) {

                    List score = [null, false];
                    bool display = !dayList[item].isAfter(_today) &&
                        ref
                            .watch(habitProvider.notifier)
                            .getTodayHabit(dayList[item])
                            .isNotEmpty;
                    
                    bool accessedPreviousScore = previousScore;
                    previousScore = false;
                    if (display) {
                      score = scoreComputing(dayList[item], ref);
                      previousScore = score[1];
                    }


                    return InkWell(
                      onTap: () {
                        _pickDay(dayList[item]);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: _selectedDay == dayList[item]
                                ? const Color.fromARGB(255, 51, 51, 51)
                                : null),
                        width: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                                DaysUtility
                                    .NumberToSign[dayList[item].weekday]!,
                                style: TextStyle(
                                    fontWeight: _today == dayList[item]
                                        ? FontWeight.bold
                                        : null,
                                    fontSize: 10,
                                    color: _today == dayList[item]
                                        ? Colors.white
                                        : Colors.grey)),
                            const SizedBox(height: 3),
                            Stack(alignment: Alignment.center,clipBehavior: Clip.none, children: [
                              if (accessedPreviousScore && score[1] && display)
                                Positioned(
                                    right: 20,
                                    child: Container(width: 20, height: 4,
                                  color: RatingUtility.getRatingColor(
                                    scoreComputing(dayList[item], ref)[0] / 2,
                                  ),
                                )),
                              Container(
                                  alignment: Alignment.center,
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: display && score[1]
                                        ? RatingUtility.getRatingColor(
                                            scoreComputing(
                                                    dayList[item], ref)[0] /
                                                2,
                                          )
                                        : _selectedDay == dayList[item]
                                            ? const Color.fromARGB(
                                                255, 51, 51, 51)
                                            : Theme.of(context)
                                                .colorScheme
                                                .surface,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 2,
                                      color: dayList[item].isAfter(_today) ||
                                              ref
                                                  .watch(habitProvider.notifier)
                                                  .getTodayHabit(dayList[item])
                                                  .isEmpty
                                          ? _selectedDay == dayList[item]
                                              ? const Color.fromARGB(
                                                  255, 51, 51, 51)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surface
                                          : RatingUtility.getRatingColor(
                                              scoreComputing(
                                                      dayList[item], ref)[0] /
                                                  2,
                                            ),
                                    ),
                                  ),
                                  child: Text(dayList[item].day.toString(),
                                      style: TextStyle(
                                        color: score[1]
                                            ? Theme.of(context)
                                                .colorScheme
                                                .surface
                                            : null,
                                      ))),
                            ])
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                height: 32,
                width: 88,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _selectedDay.isAfter(_today) ||
                            ref
                                .watch(habitProvider.notifier)
                                .getTodayHabit(_selectedDay)
                                .isEmpty
                        ? const Color.fromARGB(255, 51, 51, 51)
                        : RatingUtility.getRatingColor(score[0] / 2)
                            .withOpacity(0.75)),
                alignment: Alignment.center,
                child: Text(
                  _displayedScore(score[0]),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
