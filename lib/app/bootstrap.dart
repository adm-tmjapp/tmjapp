import 'package:firebase_core/firebase_core.dart';
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

  runApp(const TmjApp());
}
