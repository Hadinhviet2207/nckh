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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDfKGrNsmBIngi7XgdsbQyVKtwkP8VSoYw',
    appId: '1:737676321511:web:cb4a32b7f4fcef28eb7842',
    messagingSenderId: '737676321511',
    projectId: 'nhandienda',
    authDomain: 'nhandienda.firebaseapp.com',
    databaseURL: 'https://nhandienda-default-rtdb.firebaseio.com',
    storageBucket: 'nhandienda.firebasestorage.app',
    measurementId: 'G-LX5YSD9KXD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCvtNk3dZhIayPQ7bTAjkva27EtVnwG5ws',
    appId: '1:737676321511:android:7b675c33f5b8ee2deb7842',
    messagingSenderId: '737676321511',
    projectId: 'nhandienda',
    databaseURL: 'https://nhandienda-default-rtdb.firebaseio.com',
    storageBucket: 'nhandienda.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDw6rwac8QypN_SMGJpVKPD7Z_iKfQxZbc',
    appId: '1:737676321511:ios:c39e9810cdb2f12feb7842',
    messagingSenderId: '737676321511',
    projectId: 'nhandienda',
    databaseURL: 'https://nhandienda-default-rtdb.firebaseio.com',
    storageBucket: 'nhandienda.firebasestorage.app',
    iosBundleId: 'com.example.nckh',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDw6rwac8QypN_SMGJpVKPD7Z_iKfQxZbc',
    appId: '1:737676321511:ios:c39e9810cdb2f12feb7842',
    messagingSenderId: '737676321511',
    projectId: 'nhandienda',
    databaseURL: 'https://nhandienda-default-rtdb.firebaseio.com',
    storageBucket: 'nhandienda.firebasestorage.app',
    iosBundleId: 'com.example.nckh',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDfKGrNsmBIngi7XgdsbQyVKtwkP8VSoYw',
    appId: '1:737676321511:web:2c1b93a1502ef10eeb7842',
    messagingSenderId: '737676321511',
    projectId: 'nhandienda',
    authDomain: 'nhandienda.firebaseapp.com',
    databaseURL: 'https://nhandienda-default-rtdb.firebaseio.com',
    storageBucket: 'nhandienda.firebasestorage.app',
    measurementId: 'G-SYV7CGF5L8',
  );
}
