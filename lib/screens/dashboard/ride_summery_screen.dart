import 'package:flutter/material.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/custom_style.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/widgets/my_rating.dart';

class RideSummeryScreen extends StatefulWidget {
  @override
  _RideSummeryScreenState createState() => _RideSummeryScreenState();
}

class _RideSummeryScreenState extends State<RideSummeryScreen> {
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
            Strings.rideSummery,
            style: GoogleFonts.roboto(
                fontSize: Dimensions.extraLargeTextSize,
                fontWeight: FontWeight.bold,
                color: CustomColor.primaryColor),
          ),
          SizedBox(
            height: Dimensions.heightSize,
          ),
          summeryWidget(context)
        ],
      ),
    );
  }

  summeryWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.green,
                    ),
                    Text('|'),
                    Text('|'),
                    Text('|'),
                    Text('|'),
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: Dimensions.widthSize,
            ),
            Expanded(
              flex: 5,
              child: Container(
                height: 150,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mucax Booker',
                                style: GoogleFonts.roboto(
                                    color: CustomColor.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Dimensions.largeTextSize),
                              ),
                              Text(
                                'London city main road 2545/45 MH',
                                style: CustomStyle.textStyle,
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: Dimensions.widthSize),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '12:00 am',
                            style: CustomStyle.textStyle,
                          ),
                        )
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dash Park',
                                style: GoogleFonts.roboto(
                                    color: CustomColor.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Dimensions.largeTextSize),
                              ),
                              Text(
                                'Mark tower LH 2456',
                                style: CustomStyle.textStyle,
                              )
                            ],
                          ),
                        ),
                        SizedBox(width: Dimensions.widthSize),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '03:00 pm',
                            style: CustomStyle.textStyle,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: Dimensions.heightSize * 3,
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                height: 80.0,
                decoration: BoxDecoration(
                    color: Color(0xFFFDF4EC),
                    borderRadius:
                        BorderRadius.all(Radius.circular(Dimensions.radius))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Strings.distance,
                      style: CustomStyle.textStyle,
                    ),
                    SizedBox(height: Dimensions.heightSize * 0.5),
                    Text(
                      '15 km',
                      style: GoogleFonts.roboto(
                          color: CustomColor.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: Dimensions.largeTextSize),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: Dimensions.widthSize),
            Expanded(
              flex: 1,
              child: Container(
                height: 80.0,
                decoration: BoxDecoration(
                    color: Color(0xFFFAE9E9),
                    borderRadius:
                        BorderRadius.all(Radius.circular(Dimensions.radius))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      Strings.waitingTime,
                      style: CustomStyle.textStyle,
                    ),
                    SizedBox(height: Dimensions.heightSize * 0.5),
                    Text(
                      '30 m',
                      style: GoogleFonts.roboto(
                          color: CustomColor.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: Dimensions.largeTextSize),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: Dimensions.widthSize),
            Expanded(
              flex: 1,
              child: Container(
                height: 80.0,
                decoration: BoxDecoration(
                    color: Color(0xFFE9F7EB),
                    borderRadius:
                        BorderRadius.all(Radius.circular(Dimensions.radius))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Strings.totalPay,
                      style: CustomStyle.textStyle,
                    ),
                    SizedBox(height: Dimensions.heightSize * 0.5),
                    Text(
                      '\$75',
                      style: GoogleFonts.roboto(
                          color: CustomColor.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: Dimensions.largeTextSize),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: Dimensions.heightSize * 3,
        ),
        Row(
          children: [
            Image.asset(
              'assets/driver.png',
              width: 100,
              height: 100,
            ),
            SizedBox(
              width: Dimensions.widthSize,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Luchi Kubala',
                  style: GoogleFonts.roboto(
                      color: CustomColor.primaryColor,
                      fontSize: Dimensions.largeTextSize,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: Dimensions.heightSize * 0.5,
                ),
                Text(
                  'Captown City',
                  style: CustomStyle.textStyle,
                ),
                SizedBox(
                  height: Dimensions.heightSize * 0.5,
                ),
                MyRating(rating: '5'),
                SizedBox(
                  height: Dimensions.heightSize * 0.5,
                ),
                Container(
                  height: 40.0,
                  width: 110.0,
                  decoration: BoxDecoration(
                      color: Color(0xFFFCEADA),
                      borderRadius: BorderRadius.all(
                          Radius.circular(Dimensions.radius * 2))),
                  child: Center(
                    child: Text(
                      Strings.driverArrived,
                      style: GoogleFonts.roboto(color: CustomColor.accentColor),
                    ),
                  ),
                ),
              ],
            ),
          ],
        )
      ],
    );
  }
}
