import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SharedPreferences? prefs;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inicializeData();
    Timer(const Duration(seconds: 5), () {
      var token = prefs?.get(Strings.prefToken);
      if (token != null) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColor.primaryColor,
        body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              Image.asset('assets/splash.png',
                  fit: BoxFit.cover,
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width),
              Image.asset('assets/icon_white.png',
                  width: MediaQuery.of(context).size.width * 0.5),
              Padding(
                  padding: const EdgeInsets.only(
                      left: Dimensions.marginSize * 2,
                      right: Dimensions.marginSize * 2),
                  child: Text(Strings.perfectTaxiBooking,
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.largeTextSize * 1.4,
                          color: Colors.white),
                      textAlign: TextAlign.center)),
              const SizedBox(height: Dimensions.heightSize * 4),
              Container(
                  padding: const EdgeInsets.only(
                      left: Dimensions.marginSize * 4,
                      right: Dimensions.marginSize * 4),
                  width: MediaQuery.of(context).size.width,
                  height: 12.0,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6.0))),
                  child: LinearProgressIndicator(
                      backgroundColor: Colors.white,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(CustomColor.accentColor)
                      //value: 0.8,
                      ))
            ])));
  }

  Future<void> inicializeData() async {
    prefs = await SharedPreferences.getInstance();
  }
}
