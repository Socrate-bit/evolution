import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';
import 'package:tracker_v1/screens/daily_habits.dart';
import 'package:tracker_v1/screens/habit_list.dart';
import 'package:tracker_v1/screens/weekly.dart';
import 'package:tracker_v1/screens/new_habit.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String _pageTitle = 'Today';
  final List<String> _titlesList = ['Today', 'Week', 'Statistics', 'Together'];
  int _selectedIndex = 0;
  Widget _selectedPage = const DailyScreen();
  final List<Widget> _pagesList = [
    const DailyScreen(),
    const WeeklyScreen(),
    const WeeklyScreen(),
    const WeeklyScreen()
  ];
  bool isLoading = true;

  void loadData() async {
    await ref.read(userDataProvider.notifier).loadData();
    await ref.read(habitProvider.notifier).loadData();
    await ref.read(trackedDayProvider.notifier).loadData();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
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

  void deleteData() async {
    await ref.read(habitProvider.notifier).deleteDatabase('tracked_day.db');
    await ref.read(habitProvider.notifier).deleteDatabase('habits.db');
    setState() {}
    ;
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedIcon = Theme.of(context).colorScheme.secondary;

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surfaceBright,
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => MyWidget()));
                },
                icon: const Icon(
                  Icons.list,
                  size: 30,
                ),
              ),
              title: Text(_pageTitle),
              titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20),
              centerTitle: true,
            
            ),
            body: _selectedPage,
            bottomNavigationBar: BottomAppBar(
              height: 70,
              shape: const CircularNotchedRectangle(),
              notchMargin: 6.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.check_box_outlined,
                          color: _selectedIndex == 0 ? selectedIcon : null),
                      iconSize: 30,
                      onPressed: () => _onItemTapped(0)),
                  IconButton(
                      icon: Icon(Icons.event_note_rounded,
                          color: _selectedIndex == 1 ? selectedIcon : null),
                      iconSize: 30,
                      onPressed: () => _onItemTapped(1)),
                  const SizedBox(width: 48),
                  IconButton(
                      icon: Icon(Icons.bar_chart_rounded,
                          color: _selectedIndex == 2 ? selectedIcon : null),
                      iconSize: 30,
                      onPressed: () => _onItemTapped(2)),
                  IconButton(
                      icon: Icon(Icons.people_alt_outlined,
                          color: _selectedIndex == 3 ? selectedIcon : null),
                      iconSize: 30,
                      onPressed: () => _onItemTapped(3)),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              elevation: 6,
              shape: const CircleBorder(),
              onPressed: _showNewHabit,
              child: const Icon(
                Icons.add,
                size: 40,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          );
  }
}
