// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCQAY8xxKm0YwFZovLwKte9Rs4K65KpF5o',
    appId: '1:161678341679:web:644f68d8fc7cf612f038da',
    messagingSenderId: '161678341679',
    projectId: 'evolution-v1',
    authDomain: 'evolution-v1.firebaseapp.com',
    storageBucket: 'evolution-v1.appspot.com',
    measurementId: 'G-YJWHM1B0CM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCOEMUfDEwLMjJxuaGSAEr1zhmiizu14q8',
    appId: '1:161678341679:android:e1eb7cbd39ea0d5bf038da',
    messagingSenderId: '161678341679',
    projectId: 'evolution-v1',
    storageBucket: 'evolution-v1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDdr0dE3ssU_vZ_LZvz7zMKin2zBwqNNK8',
    appId: '1:161678341679:ios:debd75d36e2cf0f9f038da',
    messagingSenderId: '161678341679',
    projectId: 'evolution-v1',
    storageBucket: 'evolution-v1.appspot.com',
    iosBundleId: 'com.example.trackerV1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDdr0dE3ssU_vZ_LZvz7zMKin2zBwqNNK8',
    appId: '1:161678341679:ios:debd75d36e2cf0f9f038da',
    messagingSenderId: '161678341679',
    projectId: 'evolution-v1',
    storageBucket: 'evolution-v1.appspot.com',
    iosBundleId: 'com.example.trackerV1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQAY8xxKm0YwFZovLwKte9Rs4K65KpF5o',
    appId: '1:161678341679:web:7912f1a883692ce6f038da',
    messagingSenderId: '161678341679',
    projectId: 'evolution-v1',
    authDomain: 'evolution-v1.firebaseapp.com',
    storageBucket: 'evolution-v1.appspot.com',
    measurementId: 'G-KGKTGZGKT3',
  );

}