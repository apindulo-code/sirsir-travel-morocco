// Firebase client configuration for SirSir Travel Morocco.
// Generated from the Android and Web app registrations in Firebase project sirsir-travel-morocco.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase is currently configured for Android and Web only.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrST6rzKIqD5bHySLPTeBL84Wo-RMQZQE',
    appId: '1:881046533648:android:121caf2be99a8a063a7c95',
    messagingSenderId: '881046533648',
    projectId: 'sirsir-travel-morocco',
    storageBucket: 'sirsir-travel-morocco.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3Xk2gaPofSkdje_Se0UcUqAUjV7OvbKE',
    appId: '1:881046533648:web:6605f667a188f4383a7c95',
    messagingSenderId: '881046533648',
    projectId: 'sirsir-travel-morocco',
    authDomain: 'sirsir-travel-morocco.firebaseapp.com',
    storageBucket: 'sirsir-travel-morocco.firebasestorage.app',
    measurementId: 'G-C69CM0748L',
  );
}
