import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_v1/authentification/data/userdata_model.dart';
import 'package:tracker_v1/authentification/data/alldata_manager.dart';
import 'package:tracker_v1/authentification/data/userdata_provider.dart';
import 'package:tracker_v1/authentification/display/picture_avatar_widget.dart';
import 'package:tracker_v1/global/display/elevated_button_widget.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = false;
  bool _isAuthentifying = false;

  final _authentificater = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  File? _pickedProfilPicture;
  String? _enteredEmailAddress;
  String? _enteredUserName;
  String? _enteredPassWord;

  void _submit() async {
    if (_pickedProfilPicture == null && !_isLogin) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must pick a picture'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isAuthentifying = true;
    });

    try {
      if (!_isLogin) {
        ref.read(firestoreUploadProvider.notifier).state = true;

        await _authentificater.createUserWithEmailAndPassword(
            email: _enteredEmailAddress!, password: _enteredPassWord!);

        await ref.read(userDataProvider.notifier).addUserData(UserData(
              userId: FirebaseAuth.instance.currentUser!.uid,
              inscriptionDate: DateTime.now(),
              name: _enteredUserName!,
              profilPicture: _pickedProfilPicture!.path,
            ));

        ref.read(firestoreUploadProvider.notifier).state = false;
      } else {
        await _authentificater.signInWithEmailAndPassword(
            email: _enteredEmailAddress!, password: _enteredPassWord!);
      }
    } catch (error) {
      ref.read(firestoreUploadProvider.notifier).state = false;
      String errorMessage = error.toString();
      if (error is FirebaseAuthException) {
        errorMessage = error.message ?? errorMessage;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _isAuthentifying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceBright,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            margin: const EdgeInsets.all(50),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                  vertical: 50, horizontal: 16),
              child: Column(
                children: [
                  if (!_isLogin)
                    PictureAvatar(setPicture: (value) {
                      _pickedProfilPicture = value;
                    }),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 12),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            label:
                                Text(!_isLogin ? 'Your best email' : 'Email'),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().length < 5 ||
                                value.trim().length > 100 ||
                                !value.contains('@')) {
                              return 'Invalid email address';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredEmailAddress = newValue!.trim();
                          },
                        ),
                        if (!_isLogin) const SizedBox(height: 12),
                        if (!_isLogin)
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            textCapitalization: TextCapitalization.words,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              label: Text('How do you want me to call you?'),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length < 2 ||
                                  value.trim().length > 50) {
                                return 'Invalid username';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredUserName = newValue!.trim();
                            },
                          ),
                        const SizedBox(height: 12),
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          enableSuggestions: false,
                          obscureText: true,
                          decoration: const InputDecoration(
                            label: Text('Password'),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().length < 2 ||
                                value.trim().length > 50) {
                              return 'Invalid password';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredPassWord = newValue!.trim();
                          },
                        ),
                        const SizedBox(height: 40)
                      ],
                    ),
                  ),
                  if (!_isAuthentifying)
                    CustomElevatedButton(
                      submit: _submit,
                      text: !_isLogin ? 'Sign-up' : 'Sign-in',
                    ),
                  if (!_isAuthentifying)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                          !_isLogin
                              ? 'I have already an account'
                              : 'Create an account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.normal)),
                    ),
                  if (_isAuthentifying) const CircularProgressIndicator()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
