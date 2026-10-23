import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:tmjapp/app/tmj_app.dart';
import 'package:tmjapp/core/config/app_config.dart';
import 'package:tmjapp/core/config/app_environment.dart';
import 'package:tmjapp/firebase_options.dart';

Future<void> bootstrap({
  required AppEnvironment environment,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: environment.envFileName);
  AppConfig.initialize(environment);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (error) {
    if (error.code != 'duplicate-app') {
      rethrow;
    }
  }

  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const TmjApp());
}
