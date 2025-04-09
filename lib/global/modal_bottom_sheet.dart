import 'package:flutter/material.dart';

enum CustomModalType { actionDialog, fullPage }

class CustomModalBottomSheet extends StatelessWidget {
  const CustomModalBottomSheet(
      {this.title,
      required this.content,
      this.formKey,
      this.function,
      this.modalType = CustomModalType.fullPage,
      super.key});

  final String? title;
  final Widget content;
  final GlobalKey<FormState>? formKey;
  final CustomModalType modalType;
  final Function()? function;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: modalType == CustomModalType.fullPage ? 0 : 12,
                        ),
                        if (title != null)
                          Expanded(
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              title!,
                              style: Theme.of(context).textTheme.titleLarge!,
                            ),
                          ),
                        
                        IconButton(
                          iconSize: 30,
                          onPressed: () {
                            Navigator.of(context).pop();
                            function;
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (modalType == CustomModalType.actionDialog)
                    Divider(color: Colors.grey.withOpacity(0.25)),
                  SizedBox(
                      height: modalType == CustomModalType.fullPage ? 32 : 16),
                  content
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
