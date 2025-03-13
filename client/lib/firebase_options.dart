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
    apiKey: 'AIzaSyDuKIj8vPuYujWdbfPVkyYQie9FerBwiCY',
    appId: '1:235797705732:web:ebac0839cad13ba17f3151',
    messagingSenderId: '235797705732',
    projectId: 'di-twin',
    authDomain: 'di-twin.firebaseapp.com',
    storageBucket: 'di-twin.firebasestorage.app',
    measurementId: 'G-64SEMKFMSG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDfNE1MbD_QGNwciMBYkBIc4PwKPyWcEqU',
    appId: '1:235797705732:android:18be5ecba51b651a7f3151',
    messagingSenderId: '235797705732',
    projectId: 'di-twin',
    storageBucket: 'di-twin.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDUz-nzamDTJWZ86hvOJNa5p8yDE6bwlKU',
    appId: '1:235797705732:ios:3853ff38115e9d537f3151',
    messagingSenderId: '235797705732',
    projectId: 'di-twin',
    storageBucket: 'di-twin.firebasestorage.app',
    iosBundleId: 'com.example.client',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDUz-nzamDTJWZ86hvOJNa5p8yDE6bwlKU',
    appId: '1:235797705732:ios:3853ff38115e9d537f3151',
    messagingSenderId: '235797705732',
    projectId: 'di-twin',
    storageBucket: 'di-twin.firebasestorage.app',
    iosBundleId: 'com.example.client',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDuKIj8vPuYujWdbfPVkyYQie9FerBwiCY',
    appId: '1:235797705732:web:40d1630ce078a19c7f3151',
    messagingSenderId: '235797705732',
    projectId: 'di-twin',
    authDomain: 'di-twin.firebaseapp.com',
    storageBucket: 'di-twin.firebasestorage.app',
    measurementId: 'G-ESF11M119H',
  );

}