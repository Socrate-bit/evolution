import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/daily_recap.dart';
import 'package:tracker_v1/providers/habits_provider.dart';
import 'package:tracker_v1/providers/tracked_day.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';
import 'package:tracker_v1/models/datas/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/outlined_button.dart';

final _imagePicker = ImagePicker();

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  void logOut(ref, context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pop();
      ref.read(userDataProvider.notifier).cleanState();
      ref.read(habitProvider.notifier).cleanState();
      ref.read(trackedDayProvider.notifier).cleanState();
      ref.read(recapDayProvider.notifier).cleanState();
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void deleteAccount(context) async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
    ;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserData? userData = ref.watch(userDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            Hero(
              tag: userData!.userId!,
              child: CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(userData.profilPicture),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              userData.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
            const SizedBox(
              height: 32,
            ),
            CustomElevatedButton(
              submit: () {
                logOut(ref, context);
              },
              text: 'Log-out',
            ),
            const SizedBox(
              height: 8,
            ),
            CustomOutlinedButton(
              submit: () {
                deleteAccount(context);
              },
              text: 'Delete account',
            )
          ],
        ),
      ),
    );
  }
}
