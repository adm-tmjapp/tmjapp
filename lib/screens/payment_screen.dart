import 'package:flutter/material.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/custom_style.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/screens/add_new_card_screen.dart';
import 'package:tmjapp/screens/feedback_screen.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

// enum SingingCharacter { cash, card, mobileBanking }
enum SingingCharacter { cash }

class _PaymentScreenState extends State<PaymentScreen> {
  SingingCharacter _character = SingingCharacter.cash;

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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              top: Dimensions.heightSize * 3,
              left: Dimensions.marginSize,
              right: Dimensions.marginSize),
          child: Text(
            Strings.payment,
            style: GoogleFonts.roboto(
                fontSize: Dimensions.extraLargeTextSize,
                fontWeight: FontWeight.bold,
                color: CustomColor.primaryColor),
          ),
        ),
        SizedBox(height: Dimensions.heightSize),
        paymentWidget(context),
        SizedBox(height: Dimensions.heightSize * 3),
        Padding(
          padding: const EdgeInsets.only(
              left: Dimensions.marginSize, right: Dimensions.marginSize),
          child: GestureDetector(
            child: Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: CustomColor.primaryColor,
                  borderRadius: BorderRadius.all(
                      Radius.circular(Dimensions.radius * 0.5))),
              child: Center(
                child: Text(
                  Strings.payNow.toUpperCase(),
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: Dimensions.largeTextSize,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              _showPaymentSuccessDialog();
            },
          ),
        ),
      ],
    );
  }

  paymentWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: Dimensions.heightSize * 3,
          left: Dimensions.marginSize,
          right: Dimensions.marginSize),
      child: Column(
        children: [
          Container(
            height: 60.0,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.1)),
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radius))),
            child: ListTile(
              title: Text(
                Strings.cash.toUpperCase(),
                style: CustomStyle.textStyle,
              ),
              leading: Radio(
                value: SingingCharacter.cash,
                toggleable: true,
                autofocus: true,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    if (value != null) {
                      _character = value;
                    }
                    print('value: ' + _character.toString());
                  });
                },
              ),
            ),
          ),
          /*  SizedBox(
            height: Dimensions.heightSize,
          ),
          Container(
            height: 60.0,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.1)),
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radius))),
            child: ListTile(
              title: Row(
                children: [
                  Image.asset(
                    'assets/visa.png',
                    height: 30.0,
                  ),
                  SizedBox(
                    width: Dimensions.widthSize,
                  ),
                  Image.asset(
                    'assets/credit_card.png',
                    height: 30.0,
                  ),
                ],
              ),
              leading: Radio(
                value: SingingCharacter.card,
                toggleable: true,
                autofocus: true,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    if (value != null) {
                      _character = value;
                    }
                    print('value: ' + _character.toString());
                  });
                },
              ),
            ),
          ),
            _character.toString() == 'SingingCharacter.card'
              ? Column(
                  children: [
                    SizedBox(
                      height: Dimensions.heightSize,
                    ),
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: 1,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Image.asset(
                                'assets/visa.png',
                                height: 100.0,
                                width: 150.0,
                                fit: BoxFit.fitWidth,
                              ),
                              SizedBox(
                                width: Dimensions.widthSize,
                              ),
                              Image.asset(
                                'assets/credit_card.png',
                                height: 100.0,
                                width: 150.0,
                                fit: BoxFit.fitWidth,
                              ),
                              SizedBox(
                                width: Dimensions.widthSize,
                              ),
                              GestureDetector(
                                child: Container(
                                  height: 100.0,
                                  width: 150.0,
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(Dimensions.radius))),
                                  child: Center(
                                    child: Text(
                                      '${Strings.addNewCard.toUpperCase()} + ',
                                      style: CustomStyle.textStyle,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          AddNewCardScreen()));
                                },
                              )
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Container(),
          SizedBox(
            height: Dimensions.heightSize,
          ),
          Container(
            height: 60.0,
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black.withOpacity(0.1)),
                borderRadius:
                    BorderRadius.all(Radius.circular(Dimensions.radius))),
            child: ListTile(
              title: Text(
                Strings.mobileBanking.toUpperCase(),
                style: CustomStyle.textStyle,
              ),
              leading: Radio(
                value: SingingCharacter.mobileBanking,
                toggleable: true,
                autofocus: true,
                groupValue: _character,
                onChanged: (SingingCharacter? value) {
                  setState(() {
                    if (value != null) {
                      _character = value;
                    }
                    print('value: ' + _character.toString());
                  });
                },
              ),
            ),
          ),
        */
        ],
      ),
    );
  }

  Future<bool> _showPaymentSuccessDialog() async {
    return (await showDialog(
          barrierDismissible: true,
          context: context,
          builder: (context) => new AlertDialog(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            content: Container(
              height: MediaQuery.of(context).size.height * 0.3,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/tik.png',
                    width: 70,
                    height: 70,
                  ),
                  Text(
                    Strings.successfullyDoneYourRide,
                    style: GoogleFonts.roboto(
                        fontSize: Dimensions.extraLargeTextSize,
                        color: CustomColor.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    child: Container(
                      height: 60.0,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Color(0xFFF5F5F6),
                          borderRadius: BorderRadius.all(
                              Radius.circular(Dimensions.radius))),
                      child: Center(
                        child: Text(
                          Strings.ok.toUpperCase(),
                          style: GoogleFonts.roboto(
                              fontSize: Dimensions.extraLargeTextSize,
                              color: CustomColor.primaryColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => FeedbackScreen()));
                    },
                  )
                ],
              ),
            ),
          ),
        )) ??
        false;
  }
}
