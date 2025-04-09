import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/global/display/tool_tip_title_widget.dart';
import 'package:tracker_v1/theme.dart';

class TitledCardList extends StatelessWidget {
  const TitledCardList({
    super.key,
    this.title,
    required this.items,
    this.addTitle,
    this.addColor,
    this.addTap,
  });
  final String? title;
  final List<TitledCardItem> items;
  final String? addTitle;
  final Color? addColor;
  final void Function()? addTap;

  @override
  Widget build(BuildContext context) {
    int totalLenght = (items.length) + (addTitle != null ? 1 : 0);

    return SizedBox(
      child: Column(
        children: [
          if (title != null) CustomToolTipTitle(title: title!, content: title!),
          const SizedBox(height: 6),
          ListView.separated(
            shrinkWrap: true,
            itemCount: totalLenght,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (ctx, item) {
              if (item == totalLenght - 1 && addTitle != null) {
                return AddNewCard(
                  color: addColor,
                  title: addTitle!,
                  onTap: addTap,
                );
              }

              TitledCardItem titleCardItem = items[item];

              return BasicCard(
                leading: titleCardItem.leading,
                trailing: titleCardItem.trailing,
                title: titleCardItem.title,
                fillColor: titleCardItem.fillColor,
                onTap:
                  titleCardItem.onTap
                
              );
            },
          ),
        ],
      ),
    );
  }
}

class TitledCardItem {
  const TitledCardItem(
      {this.leading, this.title, this.trailing, this.fillColor, this.onTap});
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final Color? fillColor;

  final void Function()? onTap;
}

class BasicCard extends StatelessWidget {
  const BasicCard(
      {super.key,
      this.leading,
      this.title,
      this.trailing,
      this.fillColor,
      this.onTap});
  final Widget? leading;
  final Widget? title;
  final Widget? trailing;
  final Color? fillColor;

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    void onTapFunc() {
      if (onTap != null) {
        HapticFeedback.lightImpact();
        onTap!.call();
      }
    }

    return GestureDetector(
      onTap: onTapFunc,
      child: CardContainer(
        color: fillColor ,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            leading ?? SizedBox(),
            const SizedBox(
              width: 16,
            ),
            title ?? SizedBox(),
            const Spacer(),
            trailing ?? SizedBox(),
          ],
        ),
      ),
    );
  }
}

class AddNewCard extends ConsumerWidget {
  const AddNewCard({super.key, this.color, this.title = '', this.onTap});
  final Color? color;
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: CardContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_box_rounded,
              size: 20,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: color ?? Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final bool shadow;

  const CardContainer(
      {required this.child, super.key, this.color, this.shadow = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              boxShadow: shadow ? [basicShadow] : null,
              color: color ?? Theme.of(context).colorScheme.surfaceBright,
              borderRadius: BorderRadius.circular(10)),
          child: child),
    );
  }
}
