import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for fuchsia.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBwGG4Lt4FMzwe7YGqRsVdNnX79fGw0ljw',
    appId: '1:676772292779:android:9a6f4c9b8d5a838d77afee',
    messagingSenderId: '676772292779',
    projectId: 'tmjapp-46d78',
    storageBucket: 'tmjapp-46d78.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBfxgfOcfK_UtbjGoP4i8arl9ZaC4gvQ8U',
    appId: '1:676772292779:ios:bb59169a2273225e77afee',
    messagingSenderId: '676772292779',
    projectId: 'tmjapp-46d78',
    storageBucket: 'tmjapp-46d78.firebasestorage.app',
    iosBundleId: 'br.com.tmjapp.tmjapp',
  );
}
