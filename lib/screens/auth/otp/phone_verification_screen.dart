import 'package:flutter/material.dart';
import 'package:tmjapp/screens/auth/otp/otp_confirmation.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/screens/auth/personal_information_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String? phoneNumber;

  const PhoneVerificationScreen({Key? key, this.phoneNumber}) : super(key: key);

  @override
  _PhoneVerificationScreenState createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  TextEditingController mobileController = TextEditingController();
  String? _phoneNumber;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _phoneNumber = widget.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [verificationWidget(context)],
      ),
    );
  }

  Widget verificationWidget(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: OtpConfirmation(
              title: Strings.otpVerification,
              image: 'assets/tik.png',
              subTitle: Strings.enterOtpSentTo,
              phoneNumber: ' +' + (_phoneNumber ?? ''),
              otpLength: 4,
              validateOtp: validateOtp,
              routeCallback: moveToNextScreen,
              titleColor: Colors.black,
              themeColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> validateOtp(String otp) async {
    await Future.delayed(Duration(milliseconds: 2000));
    if (otp == "1234") {
      moveToNextScreen(context);
      return "OTP is Successfully Verified";
    } else {
      return "The entered Otp is wrong";
    }
  }

  // action to be performed after OTP validation is success
  void moveToNextScreen(context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => PersonalInformationScreen()));
  }
}
