import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyC84NBWJRW4IS0r_5KVMjw-Fh7w2uxbPwc',
    appId: '1:610520452603:web:95f7b9a9b4e97c33c9cf5e',
    messagingSenderId: '610520452603',
    projectId: 'rfid-locker-system-85ecc',
    authDomain: 'rfid-locker-system-85ecc.firebaseapp.com',
    storageBucket: "rfid-locker-system-85ecc.firebasestorage.app",
    measurementId: "G-KY06NZCXHH",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC84NBWJRW4IS0r_5KVMjw-Fh7w2uxbPwc',
    appId: '1:610520452603:android:c414d0bfd11d9a2fc9cf5e',
    messagingSenderId: '610520452603',
    projectId: 'rfid-locker-system-85ecc',
    storageBucket: "rfid-locker-system-85ecc.firebasestorage.app",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC84NBWJRW4IS0r_5KVMjw-Fh7w2uxbPwc',
    appId: '1:610520452603:ios:95f7b9a9b4e97c33c9cf5e',
    messagingSenderId: '610520452603',
    projectId: 'rfid-locker-system-85ecc',
    storageBucket: "rfid-locker-system-85ecc.firebasestorage.app",
    iosBundleId: 'com.example.rfidLockerSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC84NBWJRW4IS0r_5KVMjw-Fh7w2uxbPwc',
    appId: '1:610520452603:ios:95f7b9a9b4e97c33c9cf5e',
    messagingSenderId: '610520452603',
    projectId: 'rfid-locker-system-85ecc',
    storageBucket: "rfid-locker-system-85ecc.firebasestorage.app",
    iosBundleId: 'com.example.rfidLockerSystem',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC84NBWJRW4IS0r_5KVMjw-Fh7w2uxbPwc',
    appId: '1:610520452603:web:95f7b9a9b4e97c33c9cf5e',
    messagingSenderId: '610520452603',
    projectId: 'rfid-locker-system-85ecc',
    authDomain: 'rfid-locker-system-85ecc.firebaseapp.com',
    storageBucket: "rfid-locker-system-85ecc.firebasestorage.app",
    measurementId: "G-KY06NZCXHH",
  );
}
