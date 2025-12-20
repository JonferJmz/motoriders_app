
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - ' 
        'see https://firebase.flutter.dev/docs/platforms/web#configure-firebase',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - ' 
          'see https://firebase.flutter.dev/docs/platforms/ios#configure-firebase',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - ' 
          'see https://firebase.flutter.dev/docs/platforms/macos#configure-firebase',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - ' 
          'see https://firebase.flutter.dev/docs/platforms/windows#configure-firebase',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - ' 
          'see https://firebase.flutter.dev/docs/platforms/linux#configure-firebase',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBvbeHIwuLcTjbk-8oLEpW78qS57geN9sE",
    appId: "1:539582104272:android:78b468ee051ba3f569d4d5",
    messagingSenderId: "539582104272",
    projectId: "practica-firebase-1-1d700",
    storageBucket: "practica-firebase-1-1d700.appspot.com",
  );
}
