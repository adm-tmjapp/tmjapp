import 'package:flutter/material.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/custom_style.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/screens/payment_screen.dart';

class InvoiceScreen extends StatefulWidget {
  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
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
            Strings.userInvoice,
            style: GoogleFonts.roboto(
                fontSize: Dimensions.extraLargeTextSize,
                fontWeight: FontWeight.bold,
                color: CustomColor.primaryColor),
          ),
        ),
        SizedBox(height: Dimensions.heightSize),
        Image.asset(
          'assets/qrcode.png',
          height: 200.0,
        ),
        invoiceDetailsWidget(context),
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
                  Strings.goToPayment.toUpperCase(),
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: Dimensions.largeTextSize,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PaymentScreen()));
            },
          ),
        ),
      ],
    );
  }

  invoiceDetailsWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Dimensions.marginSize, right: Dimensions.marginSize),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      'Robert Hut',
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Phone',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      Strings.demoPhoneNumber,
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.heightSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer ID',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      '4589G',
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rider Name',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      'Robert Jon',
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.heightSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup Location',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      'Uttara, Dhaka',
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Pick off Location',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      'Bonani, Dhaka',
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.heightSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Ride',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      'Today, 12.00 PM',
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'End Ride',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      'Today 3.00 PM',
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.heightSize),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distances',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      '15 km',
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$50',
                      style: CustomStyle.textStyle,
                    ),
                    Text(
                      Strings.demoPhoneNumber,
                      style: GoogleFonts.roboto(
                          fontSize: Dimensions.defaultTextSize,
                          color: CustomColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
