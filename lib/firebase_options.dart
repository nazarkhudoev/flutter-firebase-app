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
    apiKey: 'AIzaSyCxYbdYhxnhd0CDUFgSNL3eASDuPMRZx1A',
    appId: '1:445601259293:web:57f53278e1f98818c90bf4',
    messagingSenderId: '445601259293',
    projectId: 'm41-highway',
    authDomain: 'm41-highway.firebaseapp.com',
    storageBucket: 'm41-highway.appspot.com',
    measurementId: 'G-26WG9ML6R7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPvHGbCGu-BHedbZ9vheNm2r70v0U0oWg',
    appId: '1:445601259293:android:b0ae0bb5deeeb9fac90bf4',
    messagingSenderId: '445601259293',
    projectId: 'm41-highway',
    storageBucket: 'm41-highway.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAijf5UmpRzO47NZE9_jIqKGn5aUuIDLQM',
    appId: '1:445601259293:ios:0b2fa41c7040f4a1c90bf4',
    messagingSenderId: '445601259293',
    projectId: 'm41-highway',
    storageBucket: 'm41-highway.appspot.com',
    iosClientId: '445601259293-b2tm63ls8entbs3uqadntadvn11r7gib.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAijf5UmpRzO47NZE9_jIqKGn5aUuIDLQM',
    appId: '1:445601259293:ios:0b2fa41c7040f4a1c90bf4',
    messagingSenderId: '445601259293',
    projectId: 'm41-highway',
    storageBucket: 'm41-highway.appspot.com',
    iosClientId: '445601259293-b2tm63ls8entbs3uqadntadvn11r7gib.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );
}
