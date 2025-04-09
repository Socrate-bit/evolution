// import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tracker_v1/global/display/animations.dart';
// import 'package:tracker_v1/global/display/outlined_button_widget.dart';
// import 'package:tracker_v1/global/logic/rating_display_utility.dart';
// import 'package:tracker_v1/habit_bank/data/habit_category_model.dart';
// import 'package:tracker_v1/habit_bank/data/habit_category_provider.dart';
// import 'package:tracker_v1/habit_bank/data/shared_habit_stats_state.dart';
// import 'package:tracker_v1/new_habit/data/new_habit_state.dart';
// import 'package:tracker_v1/new_habit/display/card_list_widget.dart';
// import 'package:tracker_v1/global/display/elevated_button_widget.dart';
// import 'package:tracker_v1/global/modal_bottom_sheet.dart';
// import 'package:tracker_v1/new_habit/data/habit_model.dart';
// import 'package:tracker_v1/recap/display/custom_slider_toggle_widget.dart';
// import 'package:tracker_v1/statistics/display/new_stats_screen.dart';

// class CategoryImpactField extends ConsumerWidget {
//   const CategoryImpactField({super.key});

//   Widget progressBar(double progression) {
//     return DashedCircularProgressBar.square(
//       dimensions: 40,
//       progress: 360 * (progression / 5),
//       maxProgress: 360,
//       startAngle: 225,
//       sweepAngle: 270,
//       foregroundColor: RatingDisplayUtility.ratingToColor(progression),
//       backgroundColor: Colors.white.withOpacity(0.5),
//       foregroundStrokeWidth: 5,
//       backgroundStrokeWidth: 5,
//       animation: true,
//       child: Center(
//           child: Text(progression.toString(),
//               style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
//     );
//   }

//   List<TitledCardItem> _getTitlesCardItems(
//       Map<String, double> categoryNames,
//       BuildContext context,
//       WidgetRef ref) {
//     return categoryNames.entries.map((category) {
//       Icon icon = Icon(
//         Icons.self_improvement,
//         color: Colors.white,
//       );

//       Text text = Text(
//         category.key,
//         softWrap: true,
//         maxLines: 1,
//         overflow: TextOverflow.ellipsis,
//         style: Theme.of(context).textTheme.bodyLarge,
//       );

//       return TitledCardItem(
//         onTap: () {
//           _addImpact(context, categorySelected: category);
//         },
//         leading: icon,
//         title: text,
//         fillColor: category.key.color.withOpacity(0.75),
//         trailing: progressBar(category.value),
//       );
//     }).toList();
//   }

//   void _addImpact(context, {categorySelected}) {
//     showModalBottomSheet(
//         context: context,
//         builder: (ctx) => CustomModalBottomSheet(
//               content: _NewCategoryModal(categorySelected: categorySelected),
//               title: 'Categories',
//             ));
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     Habit habitState = ref.watch(newHabitStateProvider);
//     Map<String, double> categoryNames =
//         ref.watch(sharedHabitStateProvider).categoriesRating;

//     return TitledCardList(
//         title: 'Impacts:',
//         items: _getTitlesCardItems(categoryNames, context, ref),
//         addTap: () {
//           _addImpact(context);
//         },
//         addColor: habitState.color,
//         addTitle: 'Add Impact');
//   }
// }

// class _NewCategoryModal extends ConsumerStatefulWidget {
//   const _NewCategoryModal({this.categorySelected});
//   final MapEntry<HabitCategory, double>? categorySelected;

//   @override
//   ConsumerState<_NewCategoryModal> createState() => _NewMetricModalState();
// }

// class _NewMetricModalState extends ConsumerState<_NewCategoryModal> {
//   (String?, String?)? categorySelected;
//   double? valueSelected;

//   @override
//   void initState() {
//     if (widget.categorySelected != null) {
//       categorySelected = (
//         widget.categorySelected?.key.categoryId,
//         widget.categorySelected?.key.name
//       );
//       valueSelected = widget.categorySelected?.value;
//     }

//     super.initState();
//   }

//   List<(dynamic, String)> _generateSuggestions(ref) {
//     List<HabitCategory> categories = ref.read(habitCategoryProvider);
//     return categories
//         .map((category) => (category.categoryId, category.name))
//         .toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     HabitCategory? category = ref
//         .read(habitCategoryProvider.notifier)
//         .getCategoryById(categorySelected?.$1);

//     Widget searchBar = CustomSearchBar(selectValue: (selected) {
//       setState(() {
//         categorySelected = selected;
//       });
//     }, generateSuggestion: () {
//       return _generateSuggestions(ref);
//     });

//     Widget ratingSlider = CustomToggleButtonsSlider(
//         initialValue: valueSelected ?? 0,
//         onChanged: (value) {
//           valueSelected = value;
//         },
//         toolTipTitle: 'Impact of the habit on ${categorySelected?.$2}:',
//         tooltipContent: categorySelected?.$2 ?? '');

//     Widget submitButton = CustomElevatedButton(
//       submit: () {
//         if (category == null || valueSelected == null) {
//           return;
//         }
//         ref
//             .read(sharedHabitStateProvider.notifier)
//             .addCategoryRating(category.categoryId, valueSelected!);
//         Navigator.pop(context);
//       },
//     );

//     Widget deleteButton = CustomOutlinedButton(
//       text: 'Delete',
//       submit: () {
//         ref
//             .read(sharedHabitStateProvider.notifier)
//             .deleteCategoryRating(category!);
//         Navigator.pop(context);
//       },
//     );

//     return Column(
//       children: [
//         searchBar,
//         const SizedBox(height: 32),
//         SwitcherAnimation(categorySelected != null ? ratingSlider : SizedBox()),
//         const SizedBox(height: 32),
//         submitButton,
//         const SizedBox(height: 8),
//         if (widget.categorySelected != null) deleteButton,
//       ],
//     );
//   }
// }
