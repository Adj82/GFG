import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configurable Firebase options.
///
/// Running `flutterfire configure` in this folder will overwrite this file
/// with your project's real settings (see BACKEND.md).
/// Alternatively, you can pass credentials at build time using `--dart-define`.
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
          'DefaultFirebaseOptions are not configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'AIzaSyDemoApiKeyForSocietyOS_GFG_KIIT'),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '1:100000000000:web:gfgkiitsocietyos'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '100000000000'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'gfg-kiit'),
    authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: 'gfg-kiit.firebaseapp.com'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'gfg-kiit.appspot.com'),
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'AIzaSyDemoApiKeyForSocietyOS_GFG_KIIT'),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '1:100000000000:android:gfgkiitsocietyos'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '100000000000'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'gfg-kiit'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'gfg-kiit.appspot.com'),
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'AIzaSyDemoApiKeyForSocietyOS_GFG_KIIT'),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '1:100000000000:ios:gfgkiitsocietyos'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '100000000000'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'gfg-kiit'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'gfg-kiit.appspot.com'),
    iosBundleId: 'com.gfg.kiit.societyos',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: 'AIzaSyDemoApiKeyForSocietyOS_GFG_KIIT'),
    appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '1:100000000000:ios:gfgkiitsocietyos'),
    messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '100000000000'),
    projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: 'gfg-kiit'),
    storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: 'gfg-kiit.appspot.com'),
    iosBundleId: 'com.gfg.kiit.societyos',
  );
}
