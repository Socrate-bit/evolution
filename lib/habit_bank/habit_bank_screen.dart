import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/daily/habit_list_screen.dart';
import 'package:tracker_v1/global/data/page_enum.dart';
import 'package:tracker_v1/global/display/actions_dialog.dart';
import 'package:tracker_v1/global/logic/capitalize_string.dart';
import 'package:tracker_v1/habit_bank/data/habit_category_model.dart';
import 'package:tracker_v1/habit_bank/data/habit_category_provider.dart';
import 'package:tracker_v1/habit_bank/data/shared_habit_stats_model.dart';
import 'package:tracker_v1/habit_bank/data/shared_habit_stats_provider.dart';
import 'package:tracker_v1/habit_bank/data/shared_habits_provider.dart';
import 'package:tracker_v1/habit_bank/display/category_top_habit_screen.dart';
import 'package:tracker_v1/habit_bank/habit_bank_state.dart';
import 'package:tracker_v1/new_habit/data/habit_model.dart';
import 'package:tracker_v1/new_habit/new_habit_screen.dart';
import 'package:tracker_v1/theme.dart';

class HabitsBankScreen extends ConsumerStatefulWidget {
  const HabitsBankScreen({super.key});

  @override
  ConsumerState<HabitsBankScreen> createState() => _HabitsBankScreenState();
}

class _HabitsBankScreenState extends ConsumerState<HabitsBankScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _pageNames = ['Categories', 'All Habits'];

  @override
  initState() {
    super.initState();
    _tabController =
        TabController(length: _pageNames.length, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      ref.read(habitBankStateProvider.notifier).setIndex(_tabController.index);
    });

    WidgetsBinding.instance.addPostFrameCallback((frame) {
      ref.read(habitCategoryProvider.notifier).loadDummies();
    });
  }

  @override
  void dispose() {
    // Remove the listener
    _tabController.dispose();
    super.dispose();
  }

  Widget _getPageContent(HabitBankState bankHabitState) {
    if (bankHabitState.currentIndex == 0) {
      List<HabitCategory> allCategories = ref.read(habitCategoryProvider);
      return _HabitCategories(
          _getFilteredItems(allCategories) as List<HabitCategory>);
    } else {
      List<SharedHabitStats> allHabits = ref.read(sharedHabitStatsProvider);
      return _HabitsList(
          _getFilteredItems(allHabits) as List<SharedHabitStats>);
    }
  }

  List<dynamic> _getFilteredItems(List<dynamic> allItems) {
    final HabitBankState bankHabitState = ref.read(habitBankStateProvider);

    if (bankHabitState.researchQuery.isEmpty) {
      return allItems;
    }

    return allItems.where((item) {
      return item.name
          .toLowerCase()
          .contains(bankHabitState.researchQuery.toLowerCase());
    }).toList();
  }

  List<(ModalContainerItem, bool)> getNewHabitItems() {
    return [
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
                  child: NewHabitScreen(
                      navigation: HabitListNavigation.shareHabit)),
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
                    habitListNavigation: HabitListNavigation.shareHabit)));
          },
        ),
        false
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final HabitBankState bankHabitState = ref.watch(habitBankStateProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          SizedBox(
            height: 8,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintStyle: TextStyle(color: Colors.grey),
                      hintText: 'Type to search',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(45)),
                    ),
                    onChanged: (value) => ref
                        .read(habitBankStateProvider.notifier)
                        .setResearchQuery(value),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      showActionsDialog(context, getNewHabitItems(),
                          title: 'Share An Habit');
                    },
                    icon: Icon(
                      size: 40,
                      Icons.add_rounded,
                      color: Colors.white,
                    ))
              ],
            ),
          ),
          SizedBox(
            height: 16,
          ),
          TabBar(
            tabs: <Widget>[..._pageNames.map((e) => Text(e))],
            controller: _tabController,
            onTap: (value) => HapticFeedback.selectionClick(),
          ),
          Expanded(
            child: Container(
                color: Theme.of(context).colorScheme.surfaceBright,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _getPageContent(bankHabitState)),
          ),
        ],
      ),
    );
  }
}

class _HabitsList extends ConsumerWidget {
  const _HabitsList(this.displayedHabitsStats);
  final List<SharedHabitStats> displayedHabitsStats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Habit> habitList =
        ref.read(sharedHabitsProvider).map((e) => e.$1).toList();

    return CustomCardList(habitList);
  }
}

class _HabitCategories extends ConsumerWidget {
  const _HabitCategories(this.displayedCategories);
  final List<HabitCategory> displayedCategories;

  List<GridViewItem> _getItems(items, WidgetRef ref, context) {
    void onTap(HabitCategory category) {
      Navigator.push(context,
          MaterialPageRoute(builder: (ctx) => CategoryHabitScreen(category)));
    }

    return displayedCategories.map((category) {
      int numberOfHabit = ref
          .read(sharedHabitStatsProvider)
          .where((element) => element.categoriesRating.keys
              .map((e) => e)
              .contains(category.categoryId))
          .toList()
          .length;

      return GridViewItem(
          onTap: () {
            onTap(category);
          },
          title: category.name,
          subTitle: '$numberOfHabit habits',
          color: category.color);
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _CustomGridView(_getItems(displayedCategories, ref, context));
  }
}

class GridViewItem {
  GridViewItem(
      {required this.onTap,
      required this.title,
      required this.subTitle,
      required this.color});

  Function onTap;
  String title;
  String subTitle;
  Color color;
}

class _CustomGridView extends ConsumerWidget {
  const _CustomGridView(this.items);
  final List<GridViewItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView(
      padding: EdgeInsets.symmetric(vertical: 16),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      children: [
        ...items.map((item) => InkWell(
              key: ObjectKey(item),
              onTap: () {
                item.onTap();
              },
              child: _CustomGridViewContainer(
                  title: item.title,
                  subTitle: item.subTitle,
                  color: item.color),
            )),
      ],
    );
  }
}

class _CustomGridViewContainer extends ConsumerWidget {
  final String title;
  final String subTitle;
  final Color color;

  const _CustomGridViewContainer({
    required this.title,
    required this.subTitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          boxShadow: [basicShadow],
          borderRadius: BorderRadius.circular(20),
          color: color,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            Text(subTitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: color == Theme.of(context).colorScheme.surface
                        ? Colors.grey
                        : Colors.white)),
          ],
        ),
      ),
    );
  }
}

class CustomCardList extends StatelessWidget {
  const CustomCardList(this.displayedHabit, {super.key});
  final List<Habit> displayedHabit;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 12),
      itemCount: displayedHabit.length,
      itemBuilder: (context, index) {
        return _HabitMainContainer(habit: displayedHabit[index], score: '160');
      },
    );
  }
}

class _HabitMainContainer extends ConsumerWidget {
  final Habit habit;
  final String score;

  const _HabitMainContainer({
    required this.habit,
    required this.score,
  });

  Widget _habitContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      height: 52,
      decoration: BoxDecoration(
          boxShadow: [basicShadow],
          shape: BoxShape.rectangle,
          color: habit.color.withOpacity(0.75),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget habitName = Text(
      habit.name.capitalizeString(),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Colors.white, fontSize: 16),
    );

    return _habitContainer(
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Icon(
          habit.icon,
          color: Colors.white,
        ),
        const SizedBox(
          width: 16,
        ),
        habitName,
        const Spacer(),
        SizedBox(height: 30, child: Text(score)),
      ]),
    );
  }
}
