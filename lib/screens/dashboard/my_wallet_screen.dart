import 'package:flutter/material.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/screens/add_new_card_screen.dart';

class MyWalletScreen extends StatefulWidget {
  @override
  _MyWalletScreenState createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
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
          GestureDetector(
            child: Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: CustomColor.primaryColor,
                  borderRadius: BorderRadius.all(
                      Radius.circular(Dimensions.radius * 0.5))),
              child: Center(
                child: Text(
                  Strings.addNewCard.toUpperCase() + ' +',
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: Dimensions.largeTextSize,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddNewCardScreen()));
            },
          ),
          SizedBox(
            height: Dimensions.heightSize * 3,
          ),
          Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Image.asset(
                  'assets/credit_card.png',
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  bottom: Dimensions.heightSize * 2,
                  left: Dimensions.marginSize,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.demoCardNumber,
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.largeTextSize),
                      ),
                      SizedBox(
                        height: Dimensions.heightSize,
                      ),
                      Text(
                        Strings.demoHolderName.toUpperCase(),
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.largeTextSize),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: Dimensions.heightSize * 2,
                  right: Dimensions.marginSize,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Strings.validForm.toUpperCase(),
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.defaultTextSize),
                          ),
                          Text(
                            '12/20',
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.defaultTextSize),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: Dimensions.heightSize,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Strings.validThru.toUpperCase(),
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.defaultTextSize),
                          ),
                          Text(
                            '11/25',
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.defaultTextSize),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: Dimensions.heightSize,
          ),
          Container(
            height: 250,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Image.asset(
                  'assets/visa.png',
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  bottom: Dimensions.heightSize * 2,
                  left: Dimensions.marginSize,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Strings.demoCardNumber,
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.largeTextSize),
                      ),
                      SizedBox(
                        height: Dimensions.heightSize,
                      ),
                      Text(
                        Strings.demoHolderName.toUpperCase(),
                        style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Dimensions.largeTextSize),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: Dimensions.heightSize * 2,
                  right: Dimensions.marginSize,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Strings.validForm.toUpperCase(),
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.defaultTextSize),
                          ),
                          Text(
                            '12/20',
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.defaultTextSize),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: Dimensions.heightSize,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Strings.validThru.toUpperCase(),
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.defaultTextSize),
                          ),
                          Text(
                            '11/25',
                            style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Dimensions.defaultTextSize),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
