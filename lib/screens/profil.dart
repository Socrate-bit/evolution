import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';
import 'package:tracker_v1/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _imagePicker = ImagePicker();

class ProfilScreen extends ConsumerWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // UserData? userData = ref.watch(userDataProvider);

    void logOut() async {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.of(context).pop();
      } catch (error) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.toString())));
      }

      ;
    }

    void deleteAccount() async {
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

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            // Hero(
              // tag: userData!.userId!,
              // child: CircleAvatar(
                // radius: 64,
                // backgroundImage: FileImage(userData.profilPicture),
              //),
            //),
            const SizedBox(
              height: 16,
            ),
            Text('ssalu',
              // userData.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24),
            ),
            const SizedBox(
              height: 32,
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: logOut,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary),
                child: Text(
                  'Log-out',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: deleteAccount,
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    foregroundColor: Theme.of(context).colorScheme.primary),
                child: Text('Delete account',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent.withOpacity(0.5))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
