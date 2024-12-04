import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/providers/user_stats_provider.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';
import 'package:tracker_v1/screens/habits/daily.dart';
import 'package:tracker_v1/screens/habits/habit_list.dart';
import 'package:tracker_v1/screens/others/leaderboard.dart';
import 'package:tracker_v1/screens/others/profil.dart';
import 'package:tracker_v1/screens/habits/weekly.dart';
import 'package:tracker_v1/screens/habits/new_habit.dart';
import 'package:tracker_v1/statistics_screen/statistics_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String _pageTitle = 'Today';
  final List<String> _titlesList = [
    'Today',
    'Week',
    'Statistics',
    'Leaderboard'
  ];
  int _selectedIndex = 0;
  late Widget _selectedPage;
  late List<Widget> _pagesList;

  @override
  void initState() {
    super.initState();
    _selectedPage = DailyScreen(_displayDate);
    _pagesList = [
      DailyScreen(_displayDate),
      const WeeklyScreen(),
      const StatisticsScreen(),
      const LeaderboardScreen(),
    ];
  }

  void _displayDate(value) {
    setState(() {
      _pageTitle = value;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedPage = _pagesList[index];
      _pageTitle = _titlesList[index];
    });
  }

  void _showNewHabit() {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => const NewHabitScreen());
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedIconColor = Theme.of(context).colorScheme.secondary;
    final userData = ref.watch(userDataProvider);
    ref.listen(trackedDayProvider, (t1, t2) {
      ref.read(userStatsProvider.notifier).updateStreaks();
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AllHabitsPage()));
          },
          icon: const Icon(
            Icons.list,
            size: 30,
          ),
        ),
        title: Text(_pageTitle),
        titleTextStyle: Theme.of(context).textTheme.titleLarge,
        centerTitle: true,
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const ProfilScreen()));
            },
            child: Hero(
              tag: userData!.userId!,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(userData.profilPicture),
              ),
            ),
          ),
          const SizedBox(
            width: 8,
          )
        ],
      ),
      body: _selectedPage,
      bottomNavigationBar: BottomAppBar(
        height: 60,
        shape: _selectedIndex == 0 ? const CircularNotchedRectangle() : null,
        notchMargin: 8.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconBar(0,
                selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
            IconBar(1,
                selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
            AnimatedContainer(
                duration: _selectedIndex != 0
                    ? const Duration(milliseconds: 600)
                    : const Duration(milliseconds: 300),
                width: _selectedIndex == 0 ? 80 : 0),
            IconBar(2,
                selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
            IconBar(3,
                selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _selectedIndex == 0 ? 1 : 0, // Shrink to 0 before disappearing
        duration: _selectedIndex != 0
            ? const Duration(milliseconds: 300)
            : const Duration(milliseconds: 180),
        child: FloatingActionButton(
          elevation: 6,
          shape: const CircleBorder(),
          onPressed: _showNewHabit,
          child: const Icon(
            Icons.add_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class IconBar extends StatelessWidget {
  final int selectedIndex;
  final int identityIndex;
  final Function(int) onItemTapped;

  const IconBar(this.identityIndex,
      {super.key, required this.selectedIndex, required this.onItemTapped});

  static const List<String> titleIconBar = [
    'Today',
    'Week',
    'Stats',
    'Friends'
  ];
  static const List<IconData> iconIconBar = [
    Icons.check_box_outlined,
    Icons.event_note_rounded,
    Icons.bar_chart_rounded,
    Icons.people_alt_outlined
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 1,
            child: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(iconIconBar[identityIndex],
                  color: selectedIndex == identityIndex
                      ? Theme.of(context).colorScheme.secondary
                      : null),
              iconSize: 30,
              onPressed: () => onItemTapped(identityIndex),
            ),
          ),
          Positioned(
              bottom: -9,
              child: Text(
                textAlign: TextAlign.center,
                titleIconBar[identityIndex],
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: selectedIndex == identityIndex
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey),
              ))
        ],
      ),
    );
  }
}
