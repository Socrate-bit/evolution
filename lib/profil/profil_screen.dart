import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/authentification/data/alldata_manager.dart';
import 'package:tracker_v1/authentification/data/userdata_provider.dart';
import 'package:tracker_v1/authentification/data/userdata_model.dart';
import 'package:tracker_v1/authentification/display/picture_avatar_widget.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';
import 'package:tracker_v1/global/display/outlined_button_widget.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {

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
  Widget build(BuildContext context) {
    UserData? userData = ref.watch(userDataProvider);
    bool userDataSetting = userData?.notificationActivated ?? false;
    bool userDisplaySetting = userData?.priorityDisplay ?? false;

    if (userData == null) {
      return Container();
    }

    Widget pictureAvatar = PictureAvatar(
      setPicture: (value) {
        ref
            .read(userDataProvider.notifier)
            .updateUserData(userData.copy()..profilPicture = value.path);
      },
      radius: 100,
      profilPicture: userData.profilPicture,
    );

    Widget textName = Text(
      userData.name,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
    );

    Widget logOutButton = CustomElevatedButton(
      submit: () {
        logOut(ref, context);
      },
      text: 'Log-out',
    );

    Widget deleteAccountButton = CustomOutlinedButton(
      submit: () {
        showConfirmationDigalog(context, ref, () {
          deleteAccount(ref, context);
          Navigator.of(context).pop();
        }, 'Yes I want to delete my account and all its data');
      },
      text: 'Delete your account',
    );

    Widget settingScheduledNotification = SwitchListTile(
      value: userDataSetting,
      title: Text(
        'Activate notifications',
        style: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 16),
      ),
      onChanged: (value) {
        HapticFeedback.lightImpact();
        ref.read(userDataProvider.notifier).changeNotificationSettings(value);
      },
    );

    Widget settingPriorityDisplay = SwitchListTile(
      value: userDisplaySetting,
      title: Text(
        'Activate priority display',
        style: Theme.of(context).textTheme.labelLarge!.copyWith(fontSize: 16),
      ),
      onChanged: (value) {
        HapticFeedback.lightImpact();
        ref.read(userDataProvider.notifier).changePriorityDisplaySettings(value);
      },
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            children: [
              pictureAvatar,
              const SizedBox(
                height: 16,
              ),
              textName,
              const SizedBox(
                height: 32,
              ),
              settingScheduledNotification,
              const SizedBox(
                height: 8,
              ),
              settingPriorityDisplay,
              const SizedBox(
                height: 32,
              ),
              logOutButton,
              const SizedBox(
                height: 8,
              ),
              deleteAccountButton,
            ],
          ),
        ),
      ),
    );
  }
}
