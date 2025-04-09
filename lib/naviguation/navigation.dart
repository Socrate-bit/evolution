import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:tracker_v1/authentification/data/userdata_model.dart';
import 'package:tracker_v1/daily/data/daily_screen_state.dart';
import 'package:tracker_v1/global/data/page_enum.dart';
import 'package:tracker_v1/global/display/actions_dialog.dart';
import 'package:tracker_v1/global/logic/date_utility.dart';
import 'package:tracker_v1/habit_bank/habit_bank_screen.dart';
import 'package:tracker_v1/naviguation/naviguation_state.dart';
import 'package:tracker_v1/new_habit/new_habit_screen.dart';
import 'package:tracker_v1/recap/data/habit_recap_provider.dart';
import 'package:tracker_v1/friends/data/user_stats_provider.dart';
import 'package:tracker_v1/authentification/data/userdata_provider.dart';
import 'package:tracker_v1/daily/daily_screen.dart';
import 'package:tracker_v1/daily/habit_list_screen.dart';
import 'package:tracker_v1/friends/leaderboard_screen.dart';
import 'package:tracker_v1/profil/profil_screen.dart';
import 'package:tracker_v1/statistics/statistics_screen.dart';
import 'package:tracker_v1/weekly/weekly_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late List<Widget> _pagesList;
  static const String appGroupId = 'group.productive';

  @override
  void initState() {
    HomeWidget.setAppGroupId(appGroupId);

    _pagesList = [
      HabitsBankScreen(),
      WeeklyScreen(),
      StatisticsScreen(),
      LeaderboardScreen(),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NavigationState navigationState = ref.watch(navigationStateProvider);
    UserData? userData = ref.watch(userDataProvider);

    int selectedIndex = navigationState.currentIndex;
    Widget selectedPage = _pagesList[selectedIndex];

    // Listener to update streaks
    ref.listen(habitRecapProvider, (t1, t2) {
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
    if (ref.read(navigationStateProvider).currentIndex == 0) {
      ref.read(dailyScreenStateProvider.notifier).jumpToTodayPage();
      ref.read(dailyScreenStateProvider.notifier).updateSelectedDate(today);
    }
    ref.read(navigationStateProvider.notifier).setIndex(0);
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

    Widget leftButtons = IconButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => const AllHabitsPage(
                  habitListNavigation: HabitListNavigation.habitList,
                )));
      },
      icon: const Icon(
        Icons.list,
        size: 30,
      ),
    );

    Widget rightButtons = InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (ctx) => const ProfilScreen()));
        },
        child: Hero(
          tag: userData.userId!,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.transparent,
            backgroundImage: CachedNetworkImageProvider(
              (userData.profilPicture),
            ),
          ),
        ));

    Widget title = GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          onTitleTap(ref);
        },
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: Text(
            pageTitle,
            key: ValueKey<String>(pageTitle),
          ),
        ));

    return AppBar(
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      leading: leftButtons,
      title: title,
      actions: [rightButtons],
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      centerTitle: true,
    );
  }
}

class _MyBottomAppBar extends ConsumerWidget {
  const _MyBottomAppBar();

  static const int _animationDurationShort = 300;
  static const int _animationDurationLong = 200;

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
  static final GlobalKey btnKey = GlobalKey();

  List<(ModalContainerItem, bool)> getNewHabitItems(DateTime selectedDate) {
    return [
      (
        ModalContainerItem(
          icon: Icons.diamond_rounded,
          title: 'Bank',
          onTap: (context) {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (ctx) => AllHabitsPage()));
          },
        ),
        false
      ),
      (
        ModalContainerItem(
          icon: Icons.add_rounded,
          title: 'New',
          onTap: (context) {
            showModalBottomSheet(
              isScrollControlled: true,
              context: context,
              builder: (ctx) => FractionallySizedBox(
                  heightFactor: 0.925, // Limits the height to 90% of the screen
                  child: NewHabitScreen(navigation: HabitListNavigation.addHabit)),
            );
          },
        ),
        false
      ),
      (
        ModalContainerItem(
          icon: Icons.list_rounded,
          title: 'Existing',
          onTap: (context) {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => AllHabitsPage(
                    habitListNavigation: HabitListNavigation.addHabit)));
          },
        ),
        false
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int selectedIndex = ref.read(navigationStateProvider).currentIndex;

    return AnimatedScale(
      curve: Curves.easeInOut,
      scale: selectedIndex == 0 ? 1 : 0, // Shrink to 0 before disappearing
      duration: selectedIndex != 0
          ? const Duration(milliseconds: 300)
          : const Duration(milliseconds: 180),
      child: FloatingActionButton(
        key: btnKey,
        elevation: 6,
        shape: const CircleBorder(),
        onPressed: () {
          HapticFeedback.mediumImpact();
          showActionsDialog(context,
              getNewHabitItems(ref.read(dailyScreenStateProvider).selectedDate),
              title: 'Add Task');
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
                onPressed: () {
                  HapticFeedback.selectionClick();
                  _selectIndex(identityIndex, ref);
                }),
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
