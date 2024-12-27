import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/authentification/data/userdata_model.dart';
import 'package:tracker_v1/daily/data/daily_screen_state.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/naviguation/naviguation_state.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/friends/data/user_stats_provider.dart';
import 'package:tracker_v1/authentification/data/userdata_provider.dart';
import 'package:tracker_v1/daily/daily_screen.dart';
import 'package:tracker_v1/daily/habit_list_screen.dart';
import 'package:tracker_v1/friends/leaderboard_screen.dart';
import 'package:tracker_v1/profil/profil_screen.dart';
import 'package:tracker_v1/weekly/weekly_screen.dart';
import 'package:tracker_v1/new_habit/new_habit_screen.dart';
import 'package:tracker_v1/statistics/statistics_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const List<Widget> _pagesList = [
    DailyScreen(),
    WeeklyScreen(),
    StatisticsScreen(),
    LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    NavigationState navigationState = ref.watch(navigationStateProvider);
    UserData? userData = ref.watch(userDataProvider);

    int selectedIndex = navigationState.currentIndex;
    Widget selectedPage = _pagesList[selectedIndex];

    // Listener to update streaks
    ref.listen(trackedDayProvider, (t1, t2) {
      ref.read(userStatsProvider.notifier).updateStreaks();
    });

    // No user data display
    if (userData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      appBar: _TopAppBar(),
      body: selectedPage,
      bottomNavigationBar: _MyBottomAppBar(),
      floatingActionButton: _MyFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _TopAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _TopAppBar();

  static const List<String> _titlesList = [
    'Today',
    'Week',
    'Statistics',
    'Leaderboard'
  ];

  void onTitleTap(WidgetRef ref) {
    ref.read(navigationStateProvider.notifier).setIndex(0);
    ref.read(dailyScreenStateProvider.notifier).updateSelectedDate(today);
    ref.read(dailyScreenStateProvider.notifier).jumpToTodayPage();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserData userData = ref.read(userDataProvider)!;
    int selectedIndex = ref.read(navigationStateProvider).currentIndex;
    String pageTitle = _titlesList[selectedIndex];

    if (selectedIndex == 0) {
      ref.watch(dailyScreenStateProvider);
      pageTitle =
          displayedDate(ref.watch(dailyScreenStateProvider).selectedDate);
    }

    return AppBar(
      scrolledUnderElevation: 0,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (ctx) => const AllHabitsPage()));
        },
        icon: const Icon(
          Icons.list,
          size: 30,
        ),
      ),
      title: GestureDetector(
          onTap: () {
            onTitleTap(ref);
          },
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: Text(
              pageTitle,
              key: ValueKey<String>(pageTitle),
            ),
          )),
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
            tag: userData.userId!,
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
    );
  }
}

class _MyBottomAppBar extends ConsumerWidget {
  const _MyBottomAppBar();

  static const int _animationDurationShort = 300;
  static const int _animationDurationLong = 600;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = ref.watch(navigationStateProvider).currentIndex;

    return BottomAppBar(
      height: 60,
      shape: selectedIndex == 0 ? const CircularNotchedRectangle() : null,
      notchMargin: 8.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _IconBottomAppBar(0),
          _IconBottomAppBar(1),
          AnimatedContainer(
              duration: selectedIndex != 0
                  ? const Duration(milliseconds: _animationDurationShort)
                  : const Duration(milliseconds: _animationDurationLong),
              width: selectedIndex == 0 ? 80 : 0),
          _IconBottomAppBar(2),
          _IconBottomAppBar(3),
        ],
      ),
    );
  }
}

class _MyFloatingActionButton extends ConsumerWidget {
  const _MyFloatingActionButton();

  void _openNewHabitScreen(context, DateTime selectedDate) {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        builder: (ctx) => NewHabitScreen(
              dateOpened: selectedDate,
            ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = ref.read(navigationStateProvider).currentIndex;
    DateTime selectedDate = ref.read(dailyScreenStateProvider).selectedDate;

    return AnimatedScale(
      scale: selectedIndex == 0 ? 1 : 0, // Shrink to 0 before disappearing
      duration: selectedIndex != 0
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 180),
      child: FloatingActionButton(
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () {
          _openNewHabitScreen(context, selectedDate);
        },
        child: const Icon(
          Icons.add_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _IconBottomAppBar extends ConsumerWidget {
  const _IconBottomAppBar(this.identityIndex);
  final int identityIndex;

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

  void _selectIndex(int index, WidgetRef ref) {
    ref.read(navigationStateProvider.notifier).setIndex(index);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = ref.read(navigationStateProvider).currentIndex;

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
              onPressed: () => _selectIndex(identityIndex, ref),
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
