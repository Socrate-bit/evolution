import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:flutter_iconpicker/Models/configuration.dart';

class IconPickerWidget extends StatefulWidget {
  const IconPickerWidget(
      {required this.passIcon,
      this.defaultIcon = Icons.self_improvement,
      super.key});

  final void Function(IconData icon) passIcon;
  final IconData defaultIcon;

  @override
  State<IconPickerWidget> createState() => _IconPickerWidgetState();
}

class _IconPickerWidgetState extends State<IconPickerWidget> {
  late IconData _enteredIcon;

  @override
  void initState() {
    super.initState();
    _enteredIcon = widget.defaultIcon;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Icon',
        ),
        IconButton(
            icon: Icon(_enteredIcon),
            iconSize: 40,
            onPressed: () async {
              IconPickerIcon? iconPicker = await showIconPicker(context,
                  configuration: SinglePickerConfiguration(
                      iconPackModes: [IconPack.allMaterial],
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surfaceBright
                          .withOpacity(1)));

              if (iconPicker == null) return;
              IconData icon = iconPicker.data;
              setState(() {
                _enteredIcon = icon;
              });
              widget.passIcon(icon);
            }),
      ],
    );
  }
}
