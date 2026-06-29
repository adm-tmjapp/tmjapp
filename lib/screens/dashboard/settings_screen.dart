import 'package:flutter/material.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Image.asset(
              'assets/bg.png',
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.3,
            ),
            DraggableScrollableSheet(
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radius * 3),
                          topRight: Radius.circular(Dimensions.radius * 3))),
                  child: SingleChildScrollView(
                    child: bodyWidget(context),
                    controller: scrollController,
                  ),
                );
              },
              initialChildSize: 0.77,
              minChildSize: 0.77,
              maxChildSize: 1,
            ),
          ],
        ),
      ),
    );
  }

  bodyWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Dimensions.marginSize,
          right: Dimensions.marginSize,
          top: Dimensions.heightSize * 3),
      child: Column(
        children: [
          Text(
            Strings.settings,
            style: GoogleFonts.roboto(
                fontSize: Dimensions.extraLargeTextSize,
                fontWeight: FontWeight.bold,
                color: CustomColor.primaryColor),
          ),
          SizedBox(
            height: Dimensions.heightSize * 3,
          ),
          settingsWidget(context)
        ],
      ),
    );
  }

  settingsWidget(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius:
                  BorderRadius.all(Radius.circular(Dimensions.radius))),
          child: Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.marginSize, right: Dimensions.marginSize),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.myAccount,
                  style: GoogleFonts.roboto(
                      fontSize: Dimensions.defaultTextSize,
                      color: CustomColor.primaryColor),
                ),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: 20.0,
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: Dimensions.heightSize * 0.5,
        ),
        Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius:
                  BorderRadius.all(Radius.circular(Dimensions.radius))),
          child: Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.marginSize, right: Dimensions.marginSize),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.address,
                  style: GoogleFonts.roboto(
                      fontSize: Dimensions.defaultTextSize,
                      color: CustomColor.primaryColor),
                ),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: 20.0,
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: Dimensions.heightSize * 0.5,
        ),
        Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius:
                  BorderRadius.all(Radius.circular(Dimensions.radius))),
          child: Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.marginSize, right: Dimensions.marginSize),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.paymentMethod,
                  style: GoogleFonts.roboto(
                      fontSize: Dimensions.defaultTextSize,
                      color: CustomColor.primaryColor),
                ),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: 20.0,
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: Dimensions.heightSize * 0.5,
        ),
        Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius:
                  BorderRadius.all(Radius.circular(Dimensions.radius))),
          child: Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.marginSize, right: Dimensions.marginSize),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.rideCheck,
                  style: GoogleFonts.roboto(
                      fontSize: Dimensions.defaultTextSize,
                      color: CustomColor.primaryColor),
                ),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: 20.0,
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: Dimensions.heightSize * 0.5,
        ),
        Container(
          height: 50.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Color(0xFFF8F8F8),
              borderRadius:
                  BorderRadius.all(Radius.circular(Dimensions.radius))),
          child: Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.marginSize, right: Dimensions.marginSize),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  Strings.security,
                  style: GoogleFonts.roboto(
                      fontSize: Dimensions.defaultTextSize,
                      color: CustomColor.primaryColor),
                ),
                Icon(
                  Icons.arrow_forward_ios_sharp,
                  size: 20.0,
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: Dimensions.heightSize * 0.5,
        ),
      ],
    );
  }
}
