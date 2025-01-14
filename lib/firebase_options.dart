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
    apiKey: 'AIzaSyBeq8VMC756ZZj8t4giDX0x4m5_917tYgQ',
    appId: '1:744101649306:web:72131515fccf14062db823',
    messagingSenderId: '744101649306',
    projectId: 'fir-messages-66053',
    authDomain: 'fir-messages-66053.firebaseapp.com',
    storageBucket: 'fir-messages-66053.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6aHAZXX8g1diiCsJRIK608_yLRcSdbhI',
    appId: '1:744101649306:android:4a6a348563510c8e2db823',
    messagingSenderId: '744101649306',
    projectId: 'fir-messages-66053',
    storageBucket: 'fir-messages-66053.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCjzt4Dz0Y0kV8wVdmQ3CqNK5NV-87Cp40',
    appId: '1:744101649306:ios:7b613fb2a83f3ac12db823',
    messagingSenderId: '744101649306',
    projectId: 'fir-messages-66053',
    storageBucket: 'fir-messages-66053.appspot.com',
    iosBundleId: 'com.example.sMessages',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCjzt4Dz0Y0kV8wVdmQ3CqNK5NV-87Cp40',
    appId: '1:744101649306:ios:7b613fb2a83f3ac12db823',
    messagingSenderId: '744101649306',
    projectId: 'fir-messages-66053',
    storageBucket: 'fir-messages-66053.appspot.com',
    iosBundleId: 'com.example.sMessages',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBeq8VMC756ZZj8t4giDX0x4m5_917tYgQ',
    appId: '1:744101649306:web:cdfe748f1c2f43c72db823',
    messagingSenderId: '744101649306',
    projectId: 'fir-messages-66053',
    authDomain: 'fir-messages-66053.firebaseapp.com',
    storageBucket: 'fir-messages-66053.appspot.com',
  );

}