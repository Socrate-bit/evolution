import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PictureAvatar extends StatefulWidget {
  const PictureAvatar({required this.setPicture, super.key});

  final Function(File picture) setPicture;

  @override
  State<PictureAvatar> createState() => _PictureAvatarState();
}

class _PictureAvatarState extends State<PictureAvatar> {
  final _imagePicker = ImagePicker();
  File? _pickedProfilPicture;

  void _takePicture() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage == null) return;

    setState(
      () {
        _pickedProfilPicture = File(pickedImage.path);
      },
    );

    widget.setPicture(_pickedProfilPicture!);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _takePicture,
      child: CircleAvatar(
        radius: 60,
        backgroundImage: _pickedProfilPicture == null
            ? null
            : FileImage(_pickedProfilPicture!),
        child: Icon(
          color: _pickedProfilPicture == null
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
              :  Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          Icons.photo_camera,
          size: 30,
        ),
      ),
    );
  }
}
