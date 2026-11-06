import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuração do Firebase para Memory Overclock.
class DefaultFirebaseOptions {
  static const String webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
    defaultValue: 'AIzaSyCBkpLo_seyHvGiU5wm5FVzXUsKwFisFs8',
  );
  static const String webAppId = String.fromEnvironment(
    'FIREBASE_WEB_APP_ID',
    defaultValue: '1:632920872093:web:5e09a50f827c715925f074',
  );
  static const String webMessagingSenderId = String.fromEnvironment(
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
    defaultValue: '632920872093',
  );
  static const String webProjectId = String.fromEnvironment(
    'FIREBASE_WEB_PROJECT_ID',
    defaultValue: 'memory-overclock-f8259',
  );
  static const String webAuthDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
    defaultValue: 'memory-overclock-f8259.firebaseapp.com',
  );
  static const String webStorageBucket = String.fromEnvironment(
    'FIREBASE_WEB_STORAGE_BUCKET',
    defaultValue: 'memory-overclock-f8259.firebasestorage.app',
  );
  static const String webMeasurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
    defaultValue: 'G-23DLZ6BXRC',
  );

  static bool get isConfigured => webApiKey.isNotEmpty && webAppId.isNotEmpty;

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: webApiKey,
    appId: webAppId,
    messagingSenderId: webMessagingSenderId,
    projectId: webProjectId,
    authDomain: webAuthDomain,
    storageBucket: webStorageBucket,
    measurementId: webMeasurementId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_ANDROID_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_ANDROID_APP_ID', defaultValue: ''),
    messagingSenderId: webMessagingSenderId,
    projectId: webProjectId,
    storageBucket: webStorageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: ''),
    messagingSenderId: webMessagingSenderId,
    projectId: webProjectId,
    storageBucket: webStorageBucket,
    iosBundleId: 'com.example.memoryOverclock',
  );
}
