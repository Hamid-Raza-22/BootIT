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
    apiKey: 'AIzaSyAMWcIxmmzdTuFQNZvt6jhNTH6CTshoFUs',
    appId: '1:102485570520:web:38bc8c0aeb80f86cb738ad',
    messagingSenderId: '102485570520',
    projectId: 'bookit-438707',
    authDomain: 'bookit-438707.firebaseapp.com',
    storageBucket: 'bookit-438707.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA8uucF_ZuwxXOkYhoQgDCD3FEURkTcxSY',
    appId: '1:102485570520:android:b8619b4f05bb2356b738ad',
    messagingSenderId: '102485570520',
    projectId: 'bookit-438707',
    storageBucket: 'bookit-438707.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC69MaGnsCxJYHv8KM05MSYKpUvFysxs2Q',
    appId: '1:102485570520:ios:8afa1252de1c22efb738ad',
    messagingSenderId: '102485570520',
    projectId: 'bookit-438707',
    storageBucket: 'bookit-438707.firebasestorage.app',
    iosBundleId: 'com.example.orderBookingApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC69MaGnsCxJYHv8KM05MSYKpUvFysxs2Q',
    appId: '1:102485570520:ios:8afa1252de1c22efb738ad',
    messagingSenderId: '102485570520',
    projectId: 'bookit-438707',
    storageBucket: 'bookit-438707.firebasestorage.app',
    iosBundleId: 'com.example.orderBookingApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAMWcIxmmzdTuFQNZvt6jhNTH6CTshoFUs',
    appId: '1:102485570520:web:a6a474d79b731679b738ad',
    messagingSenderId: '102485570520',
    projectId: 'bookit-438707',
    authDomain: 'bookit-438707.firebaseapp.com',
    storageBucket: 'bookit-438707.firebasestorage.app',
  );
}
