import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';

List<String> storagePaths = [
  'image_picker_04CF354F-6049-4784-B55F-C2340E306FFD-5931-000001342DAA36D4.jpg'
];

Future<File> downloadImage(String storagePath, String localPath) async {
  File file = File(localPath);
  await FirebaseStorage.instance.ref('profile_pictures/$storagePath').writeToFile(file);
  return file;
}

Future<void> uploadEditedImage(File editedFile, String storagePath) async {
  await FirebaseStorage.instance.ref('profile_pictures/$storagePath').putFile(editedFile);
}

Future<void> editImageInCloud(String storagePath, String localPath) async {
  // Step 1: Download Image
  File originalFile = await downloadImage(storagePath, localPath);

  // Step 2: Edit Image (e.g., compress)
  final editedFilePath = localPath.replaceFirst('.jpg', '_edited.jpg');
  XFile? editedFile = await FlutterImageCompress.compressAndGetFile(
    originalFile.absolute.path,
    editedFilePath,
    quality: 85,
  );

  // Step 3: Upload Edited Image
  if (editedFile != null) {
    await uploadEditedImage(File(editedFile.path), storagePath);
    print("Image edited and updated in Cloud Storage.");
  } else {
    print("Image compression failed.");
  }
}

