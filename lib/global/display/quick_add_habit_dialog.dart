import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracker_v1/global/modal_bottom_sheet.dart';
import 'package:tracker_v1/new_habit/display/frequency_picker2_widget.dart';

class _ActionsDialog extends StatelessWidget {
  const _ActionsDialog({required this.modalContainerItems, this.title});
  final List<ModalContainerItem> modalContainerItems;
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
                for (ModalContainerItem modalContainerItem
                    in modalContainerItems.sublist(
                        0, min(3, modalContainerItems.length)))
                  Expanded(
                      child: _ModalContainer(
                          modalContainerItem: modalContainerItem)),
              ],
            ),
          ),
          if (modalContainerItems.length > 3) ...[
            SizedBox(
              height: 12,
            ),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child:
                    _ModalContainer(modalContainerItem: modalContainerItems[3]))
          ]
        ],
      ),
    );
  }
}

class _ModalContainer extends StatelessWidget {
  const _ModalContainer({required this.modalContainerItem});

  final ModalContainerItem modalContainerItem;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
        modalContainerItem.onTap(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 6),
        height: 80,
        child: CustomContainerTight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(modalContainerItem.icon,
                  size: 40, color: Theme.of(context).colorScheme.primary),
              Text(modalContainerItem.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .copyWith(color: Theme.of(context).colorScheme.primary)),
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

void showActionsDialog(context, List<ModalContainerItem> modalContainerItems,
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
