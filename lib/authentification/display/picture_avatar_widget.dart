import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PictureAvatar extends StatefulWidget {
  const PictureAvatar(
      {required this.setPicture,
      this.radius = 60,
      this.profilPicture,
      super.key});

  final Function(File picture) setPicture;
  final double radius;
  final String? profilPicture;

  @override
  State<PictureAvatar> createState() => _PictureAvatarState();
}

class _PictureAvatarState extends State<PictureAvatar> {
  final _imagePicker = ImagePicker();
  File? _pickedProfilPicture;

  void _takePicture({bool gallery = false}) async {
    final pickedImage = await _imagePicker.pickImage(
        source: gallery ? ImageSource.gallery : ImageSource.camera);

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
    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(widget.radius),
          onTap: _takePicture,
          child: CircleAvatar(
            radius: widget.radius,
            backgroundImage: widget.profilPicture != null
                ? NetworkImage(widget.profilPicture!)
                : _pickedProfilPicture == null
                    ? null
                    : FileImage(_pickedProfilPicture!),
            child: Icon(
              color: _pickedProfilPicture == null
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              Icons.photo_camera,
              size: 30,
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextButton(
            onPressed: () {
              _takePicture(gallery: true);
            },
            child: const Text('Take from gallery'))
      ],
    );
  }
}
