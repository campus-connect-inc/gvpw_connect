// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDrWJ_cAudJevyecHHg2hYF4dL9TZQ4o3s',
    appId: '1:874316160398:web:3f74eed1346d4b3b6958df',
    messagingSenderId: '874316160398',
    projectId: 'campus-connect-inc',
    authDomain: 'campus-connect-inc.firebaseapp.com',
    storageBucket: 'campus-connect-inc.appspot.com',
    measurementId: 'G-E0BHXHN881',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCps8V5dDeMZm_eDO3tb0MPQbkkaURApkI',
    appId: '1:874316160398:android:bc2311a64e6124136958df',
    messagingSenderId: '874316160398',
    projectId: 'campus-connect-inc',
    storageBucket: 'campus-connect-inc.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCEGTEfL_GjUsVuOyLFALrMDguYU13EqvQ',
    appId: '1:874316160398:ios:a6f965e3edb723226958df',
    messagingSenderId: '874316160398',
    projectId: 'campus-connect-inc',
    storageBucket: 'campus-connect-inc.appspot.com',
    androidClientId: '874316160398-4vvi8irqr4tqpjsg3lv95vs25nq3fplj.apps.googleusercontent.com',
    iosClientId: '874316160398-apm0di2vkstj4bdv27elmk2vjsuonk7s.apps.googleusercontent.com',
    iosBundleId: 'com.connect.gvpcew',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCEGTEfL_GjUsVuOyLFALrMDguYU13EqvQ',
    appId: '1:874316160398:ios:a6f965e3edb723226958df',
    messagingSenderId: '874316160398',
    projectId: 'campus-connect-inc',
    storageBucket: 'campus-connect-inc.appspot.com',
    androidClientId: '874316160398-4vvi8irqr4tqpjsg3lv95vs25nq3fplj.apps.googleusercontent.com',
    iosClientId: '874316160398-apm0di2vkstj4bdv27elmk2vjsuonk7s.apps.googleusercontent.com',
    iosBundleId: 'com.connect.gvpcew',
  );
}