import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/data_manager.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';
import 'package:tracker_v1/models/datas/user.dart';
import 'package:tracker_v1/widgets/auth/picture_avatar.dart';
import 'package:tracker_v1/widgets/global/elevated_button.dart';
import 'package:tracker_v1/widgets/global/outlined_button.dart';
import 'package:tracker_v1/widgets/global/waiting.dart';

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  void logOut(ref, context) async {
    Navigator.of(context).pop();
    try {
      await ref.read(dataManagerProvider).signOut();
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void deleteAccount(ref, context) async {
    try {
      await ref.read(dataManagerProvider).deleteAccount();
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
    Navigator.of(context).pop();
  }

  void showConfirmationDigalog(context, ref, Function() function, String text) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [CustomOutlinedButton(submit: function, text: text)],
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure? This operation is irreversible.',
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserData? userData = ref.watch(userDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            children: [
              PictureAvatar(
                setPicture: (value) {
                  ref.read(userDataProvider.notifier).updateUserData(
                      userData.copy()..profilPicture = value.path);
                },
                radius: 100,
                profilPicture: userData!.profilPicture,
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
                  showConfirmationDigalog(context, ref, () {
                    deleteAccount(ref, context);
                    Navigator.of(context).pop();
                  }, 'Yes I want to delete my account and all its data');
                },
                text: 'Delete your account',
              )
            ],
          ),
        ),
      ),
    );
  }
}
