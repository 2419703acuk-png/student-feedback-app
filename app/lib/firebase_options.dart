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
    apiKey: 'AIzaSyBwk8NM9JcFck2xgC8V0u4na1_aeHzItNQ',
    appId: '1:700174697733:android:d3dd1dba0afaa1a824236c',
    messagingSenderId: '700174697733',
    projectId: 'student-feedback-app-c7e5a',
    authDomain: 'student-feedback-app-c7e5a.firebaseapp.com',
    storageBucket: 'student-feedback-app-c7e5a.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBwk8NM9JcFck2xgC8V0u4na1_aeHzItNQ',
    appId: '1:700174697733:android:d3dd1dba0afaa1a824236c',
    messagingSenderId: '700174697733',
    projectId: 'student-feedback-app-c7e5a',
    storageBucket: 'student-feedback-app-c7e5a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBwk8NM9JcFck2xgC8V0u4na1_aeHzItNQ',
    appId: '1:700174697733:android:d3dd1dba0afaa1a824236c',
    messagingSenderId: '700174697733',
    projectId: 'student-feedback-app-c7e5a',
    storageBucket: 'student-feedback-app-c7e5a.firebasestorage.app',
    iosBundleId: 'com.feedback.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBwk8NM9JcFck2xgC8V0u4na1_aeHzItNQ',
    appId: '1:700174697733:android:d3dd1dba0afaa1a824236c',
    messagingSenderId: '700174697733',
    projectId: 'student-feedback-app-c7e5a',
    storageBucket: 'student-feedback-app-c7e5a.firebasestorage.app',
    iosBundleId: 'com.feedback.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBwk8NM9JcFck2xgC8V0u4na1_aeHzItNQ',
    appId: '1:700174697733:android:d3dd1dba0afaa1a824236c',
    messagingSenderId: '700174697733',
    projectId: 'student-feedback-app-c7e5a',
    storageBucket: 'student-feedback-app-c7e5a.firebasestorage.app',
  );
}
