import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/new_habit/display/frequency_picker2_widget.dart';

void showActionsDialog(
    context, List<(ModalContainerItem, bool)> modalContainerItems,
    {String? title}) {
  showModalBottomSheet(
    useSafeArea: true,
    isScrollControlled: true,
    context: context,
    builder: (ctx) => _ActionsDialog(
      modalContainerItems: modalContainerItems,
      title: title,
    ),
  );
}

class _ActionsDialog extends StatelessWidget {
  const _ActionsDialog({required this.modalContainerItems, this.title});
  final List<(ModalContainerItem, bool)> modalContainerItems;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return CustomModalBottomSheet(
      modalType: CustomModalType.actionDialog,
      title: title,
      content: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (modalContainerItems.length > 1) ...[
                  for ((ModalContainerItem, bool) modalContainerItem
                      in modalContainerItems.sublist(
                          1, min(modalContainerItems.length, 4)))
                    Expanded(
                        child: _ModalContainer(
                            disabled: modalContainerItem.$2,
                            modalContainerItem: modalContainerItem.$1)),
                ]
              ],
            ),
          ),
          if (modalContainerItems.length > 1)
            SizedBox(
              height: 12,
            ),
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: _ModalContainer(
                  modalContainerItem: modalContainerItems[0].$1))
        ],
      ),
    );
  }
}

class _ModalContainer extends StatelessWidget {
  const _ModalContainer(
      {required this.modalContainerItem, this.disabled = false});

  final ModalContainerItem modalContainerItem;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: disabled ? Colors.transparent : null,
      onTap: () {
        if (disabled) return;
        HapticFeedback.lightImpact();
        modalContainerItem.onTap(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        height: 80,
        child: CustomContainerTight(
          color: !disabled
              ? null
              : Theme.of(context).colorScheme.surfaceBright.withOpacity(0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(modalContainerItem.icon,
                  size: 40,
                  color: !disabled
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withOpacity(0.3)),
              Text(modalContainerItem.title,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: !disabled
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.withOpacity(0.3))),
            ],
          ),
        ),
      ),
    );
  }
}

class ModalContainerItem {
  const ModalContainerItem(
      {required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final Function onTap;
}
