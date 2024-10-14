import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';
import 'package:tracker_v1/screens/habits/daily.dart';
import 'package:tracker_v1/screens/habits/habit_list.dart';
import 'package:tracker_v1/screens/others/garden.dart';
import 'package:tracker_v1/screens/others/profil.dart';
import 'package:tracker_v1/screens/habits/weekly.dart';
import 'package:tracker_v1/screens/habits/new_habit.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  String _pageTitle = 'Today';
  final List<String> _titlesList = ['Today', 'Week', 'Statistics', 'Together'];
  int _selectedIndex = 0;
  late Widget _selectedPage;
  late List<Widget> _pagesList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _selectedPage = DailyScreen(_displayDate);
    _pagesList = [
      DailyScreen(_displayDate),
      const WeeklyScreen(),
      const GardenScreen(),
      const GardenScreen()
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
    final Color selectedIcon = Theme.of(context).colorScheme.secondary;
    final userData = ref.watch(userDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (ctx) => const HabitList()));
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
        height: 70,
        shape: _selectedIndex == 0 ? const CircularNotchedRectangle() : null,
        notchMargin: 8.0 ,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: IconButton(
                  icon: Icon(Icons.check_box_outlined,
                      color: _selectedIndex == 0 ? selectedIcon : null),
                  iconSize: 30,
                  onPressed: () => _onItemTapped(0)),
            ),
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.event_note_rounded,
                        color: _selectedIndex == 1 ? selectedIcon : null),
                    iconSize: 30,
                    onPressed: () => _onItemTapped(1))),
            AnimatedContainer(
                duration: _selectedIndex != 0
                    ? const Duration(milliseconds: 600)
                    : const Duration(milliseconds: 300),
                width: _selectedIndex == 0 ? 80 : 0),
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.bar_chart_rounded,
                        color: _selectedIndex == 2 ? selectedIcon : null),
                    iconSize: 30,
                    onPressed: () => _onItemTapped(2))),
            Expanded(
                child: IconButton(
                    icon: Icon(Icons.people_alt_outlined,
                        color: _selectedIndex == 3 ? selectedIcon : null),
                    iconSize: 30,
                    onPressed: () => _onItemTapped(3))),
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
