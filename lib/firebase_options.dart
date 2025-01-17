import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBYc17gAQl4tJmkk5nQcH0aw9UCtZ4ylnc',
    appId: '1:786441533391:android:c5dd6a18a73a88180704ba',
    messagingSenderId: '786441533391',
    projectId: 'antarkanma-98fde',
    storageBucket: 'antarkanma-98fde.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCHqeswHvbCbYllfkvzCbQAKNLUx11hs3Q',
    appId: '1:786441533391:web:b2f8e7de1c5cfe9a0704ba',
    messagingSenderId: '786441533391',
    projectId: 'antarkanma-98fde',
    authDomain: 'antarkanma-98fde.firebaseapp.com',
    storageBucket: 'antarkanma-98fde.firebasestorage.app',
    measurementId: 'G-0DJ37WCT04',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDZ3ug6YWRoypgihYr0CCEIHRcitdRnKyA',
    appId: '1:786441533391:ios:677be198d4f089930704ba',
    messagingSenderId: '786441533391',
    projectId: 'antarkanma-98fde',
    storageBucket: 'antarkanma-98fde.firebasestorage.app',
    iosBundleId: 'com.example.antarkanma',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZ3ug6YWRoypgihYr0CCEIHRcitdRnKyA',
    appId: '1:786441533391:ios:677be198d4f089930704ba',
    messagingSenderId: '786441533391',
    projectId: 'antarkanma-98fde',
    storageBucket: 'antarkanma-98fde.firebasestorage.app',
    iosBundleId: 'com.example.antarkanma',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCHqeswHvbCbYllfkvzCbQAKNLUx11hs3Q',
    appId: '1:786441533391:web:7aae69fe8df309c20704ba',
    messagingSenderId: '786441533391',
    projectId: 'antarkanma-98fde',
    authDomain: 'antarkanma-98fde.firebaseapp.com',
    storageBucket: 'antarkanma-98fde.firebasestorage.app',
    measurementId: 'G-YLSK93M6XC',
  );

}