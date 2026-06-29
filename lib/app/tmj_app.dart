import 'package:flutter/material.dart';

import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/utils/colors.dart';

class TmjApp extends StatelessWidget {
  const TmjApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: CustomColor.accentColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRoutes.splash,
    );
  }
}
