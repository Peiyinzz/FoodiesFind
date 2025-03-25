// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2E0OZSVn_CiqI1j7-HtbOJVq6J1LCRow',
    appId: '1:57555916564:android:e0ef840c16b9ec9e145401',
    messagingSenderId: '57555916564',
    projectId: 'foodiesfind-21552',
    storageBucket: 'foodiesfind-21552.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyA2E0OZSVn_CiqI1j7-HtbOJVq6J1LCRow",
    authDomain: "foodiesfind-21552.firebaseapp.com",
    projectId: "foodiesfind-21552",
    storageBucket: "foodiesfind-21552.firebasestorage.app",
    messagingSenderId: "57555916564",
    appId: "1:57555916564:web:17ca98b938c85602145401",
    measurementId: "G-0EECZ5G0TV",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.example.frontend_backup',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-api-key',
    appId: 'your-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.example.frontend_backup',
  );
}
