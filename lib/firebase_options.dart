// IMPORTANTE: Este archivo debe ser generado con FlutterFire CLI.
// Ejecuta en tu terminal:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Reemplaza los valores placeholder con los de tu proyecto Firebase.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBqOkt8hzxmnHuZ8dWyF5LE7mnH2MhGuag',
    appId: '1:774137426536:web:86784c98237c4d596d01dd',
    messagingSenderId: '774137426536',
    projectId: 'greenwatch12',
    authDomain: 'greenwatch12.firebaseapp.com',
    storageBucket: 'greenwatch12.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCa9egU52nN7Ge3W5-PLhUJ76H_ea9xxXk',
    appId: '1:774137426536:android:89571d1008ed14ea6d01dd',
    messagingSenderId: '774137426536',
    projectId: 'greenwatch12',
    storageBucket: 'greenwatch12.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBoZW3H-WkrS9ltTUC2asU2bu2dPks1PeQ',
    appId: '1:774137426536:ios:1b49c34400f178ce6d01dd',
    messagingSenderId: '774137426536',
    projectId: 'greenwatch12',
    storageBucket: 'greenwatch12.firebasestorage.app',
    iosClientId: '774137426536-d9i6srcre25thp4g8uceg8d381ai7rc3.apps.googleusercontent.com',
    iosBundleId: 'com.example.flutterApplication1',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosClientId: 'YOUR_MACOS_CLIENT_ID',
    iosBundleId: 'com.example.flutter_application_1',
  );
}
