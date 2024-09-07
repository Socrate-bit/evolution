import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tracker_v1/models/user.dart';
import 'package:tracker_v1/providers/userdata_provider.dart';

final _imagePicker = ImagePicker();
final _authentificater = FirebaseAuth.instance;

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = false;
  bool _isAuthentifying = false;

  final _formKey = GlobalKey<FormState>();

  File? _pickedProfilPicture;
  String? _enteredEmailAddress;
  String? _enteredUserName;
  String? _enteredPassWord;

  void _takePicture() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.camera);

    if (pickedImage == null) return;

    setState(
      () {
        _pickedProfilPicture = File(pickedImage.path);
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save(); 
    _isAuthentifying = true;

    try {
      if (!_isLogin) {
        print(_enteredEmailAddress);
        print(_enteredPassWord);
        print(_enteredUserName);
        await _authentificater.createUserWithEmailAndPassword(
            email: _enteredEmailAddress!, password: _enteredPassWord!);

        ref.read(userDataProvider.notifier).addUserData(
              UserData(
                  inscriptionDate: DateTime.now(),
                  name: _enteredUserName!,
                  profilPicture: _pickedProfilPicture!
                  ),
            );
      } else {
        await _authentificater.signInWithEmailAndPassword(
            email: _enteredEmailAddress!, password: _enteredPassWord!);
      }
    } catch (error) {
      String errorMessage = error.toString();
      if (error is FirebaseAuthException) {
        errorMessage = error.message ?? errorMessage;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    }

    _isAuthentifying = false;
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
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _pickedProfilPicture == null
                          ? null
                          : FileImage(_pickedProfilPicture!),
                      child: IconButton(
                        color: _pickedProfilPicture == null
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.8)
                            : Colors.grey.withOpacity(0.4),
                        icon: const Icon(
                          Icons.photo_camera,
                          size: 30,
                        ),
                        onPressed: _takePicture,
                      ),
                    ),
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
                                Text(!_isLogin ? "Your best email" : "Email"),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().length < 5 ||
                                value.trim().length > 100 ||
                                !value.contains("@")) {
                              return "Invalid email address";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredEmailAddress = newValue;
                          },
                        ),
                        if (!_isLogin) const SizedBox(height: 12),
                        if (!_isLogin)
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            textCapitalization: TextCapitalization.words,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              label: Text("How do you want me to call you?"),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length < 5 ||
                                  value.trim().length > 50) {
                                return "Invalid username";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enteredUserName = newValue;
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
                            label: Text("Password"),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().length < 10 ||
                                value.trim().length > 50) {
                              return "Invalid password";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredPassWord = newValue;
                          },
                        ),
                        const SizedBox(height: 40)
                      ],
                    ),
                  ),
                  if (!_isAuthentifying)
                    FilledButton(
                      onPressed: _submit,
                      child: Text(!_isLogin ? "Sign-up" : "Sign-in"),
                    ),
                  if (!_isAuthentifying)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(!_isLogin
                          ? "I have already an account"
                          : "Create an account"),
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
