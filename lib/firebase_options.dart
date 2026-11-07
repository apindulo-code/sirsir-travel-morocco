// Firebase client configuration for SirSir Travel Morocco (Android).
// Generated from the Android app registration in Firebase project sirsir-travel-morocco.
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase web configuration has not been registered for this project.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Firebase is currently configured for Android only.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrST6rzKIqD5bHySLPTeBL84Wo-RMQZQE',
    appId: '1:881046533648:android:3747754613450c773a7c95',
    messagingSenderId: '881046533648',
    projectId: 'sirsir-travel-morocco',
    storageBucket: 'sirsir-travel-morocco.firebasestorage.app',
  );
}
