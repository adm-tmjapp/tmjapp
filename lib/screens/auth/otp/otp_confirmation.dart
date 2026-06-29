import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/screens/dashboard_screen.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/custom_style.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// ignore: must_be_immutable
class OtpConfirmation extends StatefulWidget {
  final String? title;
  final String? subTitle;
  final String? image;
  final String? phoneNumber;
  final Future<String> Function(String)? validateOtp;
  final void Function(BuildContext)? routeCallback;
  Color? topColor;
  Color? bottomColor;
  bool? _isGradientApplied;
  final Color? titleColor;
  final Color? themeColor;
  final Color? keyboardBackgroundColor;
  final Widget? icon;

  /// default [otpLength] is 4
  final int? otpLength;

  OtpConfirmation({
    Key? key,
    this.title = "Verification Code",
    this.subTitle = "please enter the OTP sent to your\n device",
    this.otpLength = 4,
    @required this.validateOtp,
    @required this.routeCallback,
    this.themeColor = Colors.black,
    this.titleColor = Colors.black,
    @required this.icon,
    this.keyboardBackgroundColor,
    this.image,
    this.phoneNumber,
  }) : super(key: key) {
    this._isGradientApplied = false;
  }

  OtpConfirmation.withGradientBackground(
      {Key? key,
      this.title = "Verification Code",
      this.subTitle = "please enter the OTP sent to your\n device",
      this.otpLength = 4,
      @required this.validateOtp,
      @required this.routeCallback,
      this.themeColor = Colors.white,
      this.titleColor = Colors.white,
      @required this.topColor,
      @required this.bottomColor,
      this.keyboardBackgroundColor,
      this.icon,
      this.image,
      this.phoneNumber})
      : super(key: key) {
    this._isGradientApplied = true;
  }

  @override
  _OtpConfirmationState createState() => new _OtpConfirmationState();
}

class _OtpConfirmationState extends State<OtpConfirmation>
    with SingleTickerProviderStateMixin {
  Size? _screenSize;
  int? _currentDigit;
  List<int>? otpValues;
  bool showLoadingButton = false;
  String otpValue = '';

  @override
  void initState() {
    otpValues = List<int>.filled(widget.otpLength ?? 0, 0, growable: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(10),
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
            decoration: widget._isGradientApplied ?? false
                ? BoxDecoration(
                    gradient: LinearGradient(
                    colors: [
                      widget.topColor ?? Colors.transparent,
                      widget.bottomColor ?? Colors.transparent
                    ],
                    begin: FractionalOffset.topLeft,
                    end: FractionalOffset.bottomRight,
                    stops: [0, 1],
                    tileMode: TileMode.clamp,
                  ))
                : BoxDecoration(color: Colors.white),
            width: _screenSize?.width ?? 0,
            child: _getInputPart,
          ),
        ],
      ),
    );
  }

  /// Return Title label
  get _getTitleText {
    return new Text(
      widget.title ?? "",
      style: GoogleFonts.roboto(
          color: Colors.black, fontSize: Dimensions.extraLargeTextSize * 1.5),
    );
  }

  /// Return subTitle label
  get _getSubtitleText {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.subTitle ?? "",
          style: CustomStyle.textStyle,
        ),
        Text(widget.phoneNumber ?? "",
            style: GoogleFonts.roboto(
                color: Colors.black, fontSize: Dimensions.largeTextSize)),
      ],
    );
  }

  /// Return "OTP" input fields
  // get _getInputField {
  //   return new Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: getOtpTextWidgetList(),
  //   );
  // }
  get _getInputField {
    return PinCodeTextField(
      appContext: context,
      length: widget.otpLength ?? 4,
      keyboardType: TextInputType.number,
      onChanged: (value) {
        // Handle OTP changes if needed
      },
      onCompleted: (value) {
        // Handle OTP completion and validation
        widget.validateOtp!(value).then((response) {
          if (response == null) {
            widget.routeCallback!(context);
          } else if (response.isNotEmpty) {
            showToast(context, response);
            clearOtp();
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => DashboardScreen()));
          }
        });
      },
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(5),
        fieldHeight: 50,
        fieldWidth: 50,
        activeFillColor: Colors.white,
        inactiveFillColor: Colors.grey[200],
        activeColor: widget.themeColor ?? Colors.black,
        inactiveColor: widget.themeColor ?? Colors.black,
      ),
    );
  }

  /// Returns otp fields of length [widget.otpLength]
  List<Widget> getOtpTextWidgetList() {
    // ignore: deprecated_member_use
    List<Widget> otpList = [];
    final int otpLength = widget.otpLength ?? 0; // Ensure otpLength is not null
    for (int i = 0; i < otpLength; i++) {
      otpList.add(_otpTextField(otpValues![i]));
    }
    return otpList;
  }

  /// Returns Otp screen views
  get _getInputPart {
    return new Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: Dimensions.marginSize),
              child: GestureDetector(
                child: Icon(Icons.arrow_back),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
        widget.icon != null
            ? IconButton(
                icon: widget.icon!,
                iconSize: 60,
                onPressed: () {},
              )
            : Container(
                width: 0,
                height: 0,
              ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _getTitleText,
        ),
        SizedBox(
          height: Dimensions.heightSize,
        ),
        Image.asset(
          widget.image ?? "",
          height: 120.0,
          width: 120,
          fit: BoxFit.contain,
        ),

        SizedBox(
          height: Dimensions.heightSize * 3,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _getSubtitleText,
        ),
        SizedBox(
          height: Dimensions.heightSize,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
          child: _getInputField,
        ),
        showLoadingButton
            ? Center(child: CircularProgressIndicator())
            : Container(
                width: 0,
                height: 0,
              ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Strings.didntGetOtpCode,
              style: CustomStyle.textStyle,
            ),
            Text(
              Strings.resend.toUpperCase(),
              style: GoogleFonts.roboto(
                  fontSize: Dimensions.defaultTextSize,
                  color: CustomColor.accentColor,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        // _getOtpKeyboard
      ],
    );
  }

  void _setCurrentDigit(String value) {
    setState(() {
      otpValue = value;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Returns "Otp text field"
  Widget _otpTextField(int? digit) {
    return new Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: new Text(
        digit.toString(),
        style: new TextStyle(
          fontSize: 30.0,
          color: widget.titleColor,
        ),
      ),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 2.0,
        color: widget.titleColor ?? Colors.transparent,
      ))),
    );
  }

  ///to clear otp when error occurs
  void clearOtp() {
    otpValues = List<int>.filled(widget.otpLength ?? 0, 0, growable: false);
    setState(() {});
  }

  ///to show error  message
  showToast(BuildContext context, String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
