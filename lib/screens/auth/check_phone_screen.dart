import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/screens/auth/sign_up_screen.dart';
import 'package:tmjapp/screens/dashboard_screen.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:tmjapp/utils/custom_style.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/strings.dart';

class CheckPhoneSceen extends StatefulWidget {
  @override
  _CheckPhoneSceenState createState() => _CheckPhoneSceenState();
}

class _CheckPhoneSceenState extends State<CheckPhoneSceen> {
  SharedPreferences? prefs ;
  String? number;
  String selectedCounty = 'Brasil';
  CountryCode? selectedCountryCode = CountryCode.fromDialCode("+55");
  TextEditingController phoneController = TextEditingController();
  TextEditingController tokenController = TextEditingController();
  final GlobalKey<FormFieldState> _formKeyPhone = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _formKeyToken = GlobalKey<FormFieldState>();



  //bool _toggleVisibility = true;
  bool checkRememberMe = false;
  bool _hasErrorPhone = false;
  bool _hasErrorToken = false;
  bool IsVisibleToken = false;
  


  var maskFormatterNumber =  MaskTextInputFormatter(
  mask: '(##) #####-#### -####', 
  filter: { "#": RegExp(r'[0-9]') },
  type: MaskAutoCompletionType.lazy
);

  @override
  void initState(){
    super.initState();
    checkData();
  }
  
  Future<void> checkData() async {
    prefs = await SharedPreferences.getInstance();
    phoneController.text = '';
    number = prefs?.getString(Strings.prefNumber);
    if(number != null && number!.isNotEmpty){
      setState(() {
        checkRememberMe = true;
        phoneController.text = number ?? "";
      });
    }
  }

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
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radius * 3),
                          topRight: Radius.circular(Dimensions.radius * 3))),
                  child: SingleChildScrollView(
                    child: signInWidget(context),
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

  signInWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Dimensions.marginSize,
          right: Dimensions.marginSize,
          top: Dimensions.heightSize * 3),
      child: (Column(
        children: [
          Text(
            Strings.signInAccount,
            style: GoogleFonts.roboto(
                fontSize: Dimensions.extraLargeTextSize,
                fontWeight: FontWeight.bold,
                color: CustomColor.primaryColor),
          ),
          const SizedBox(
            height: Dimensions.heightSize * 3,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom:8.0),
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black.withOpacity(0.1)),
                  borderRadius:
                      const BorderRadius.all(Radius.circular(Dimensions.radius * 0.5))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CountryCodePicker(
                    onChanged: (CountryCode countryCode) {
                      setState(() {
                        selectedCountryCode = countryCode;
                        selectedCounty = countryCode.name ?? "";
                      });
                    },
                    initialSelection: selectedCountryCode?.code ,
                    favorite: const [
                      '+1',
                      '+55'
                    ], // Add your favorite country codes here
                    showCountryOnly:
                        false, // Set to true to show only country names
                    showOnlyCountryWhenClosed:
                        false, // Set to true to show only the selected country when closed
                    alignLeft: false, // Set to true for left alignment
                    padding: EdgeInsets.zero, // Adjust padding as needed
                    textStyle: CustomStyle.textStyle, // Customize text style
                  ),
                  SizedBox(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: TextFormField(
                      key: _formKeyPhone,
                      inputFormatters: [maskFormatterNumber],
                      style: CustomStyle.textStyle,
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      validator: (String? value) {
                        if (value!.isEmpty) {
                          return Strings.pleaseFillOutTheField;
                        } else {
                          return null;
                        }
                      },
                      decoration: InputDecoration(
                        errorStyle: const TextStyle(color: Colors.red),
                        errorText: _hasErrorPhone ? Strings.invalidPhone : null,
                        hintText: Strings.phone,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        labelStyle: CustomStyle.textStyle,
                        filled: true,
                        fillColor: Colors.white,
                        hintStyle: CustomStyle.textStyle,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Visibility(
          visible: IsVisibleToken,
          child: SizedBox(
                height: 50.0,
                width: MediaQuery.of(context).size.width / 1.8,
                child: TextFormField(
                  key: _formKeyToken,
                  style: CustomStyle.textStyle,
                  controller: tokenController,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value!.isEmpty) {
                      return Strings.pleaseFillOutTheField;
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    errorStyle: const TextStyle(color: Colors.red),
                    errorText: _hasErrorToken ? Strings.invalidToken : null,
                    hintText: Strings.token,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                    labelStyle: CustomStyle.textStyle,
                    filled: true,
                    fillColor: Colors.white,
                    hintStyle: CustomStyle.textStyle,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                  ),
                ),
              ),
        ),

          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: CheckboxListTile(
                  selected: checkRememberMe,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    Strings.rememberMe,
                    style: CustomStyle.textStyle,
                  ),
                  value: checkRememberMe,
                  onChanged: (newValue) async {
                    if(newValue != null && newValue){
                          await prefs?.setString(Strings.prefNumber, phoneController.text);
                        }else{
                          await prefs?.remove(Strings.prefNumber);
                        }
                    setState(() {
                      if (newValue != null) {
                        checkRememberMe = newValue;
                      }
                    });
                    
                  },
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading
                  // Checkbox
                ),
              ),
              GestureDetector(
                child: Text(
                  Strings.loginforEmail,
                  style: TextStyle(
                      fontSize: Dimensions.defaultTextSize,
                      color: CustomColor.blueColor,
                      decoration: TextDecoration.underline),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(
            height: Dimensions.heightSize * 1,
          ),
          GestureDetector(
            child: Container(
              height: 50.0,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                  color: CustomColor.primaryColor,
                  borderRadius: BorderRadius.all(
                      Radius.circular(Dimensions.radius * 0.5))),
              child: Center(
                child: Text(
                  Strings.signIn.toUpperCase(),
                  style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: Dimensions.largeTextSize,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()
                      // builder: (context) => FullViewMap()
                      ));
            },
          ),
          const SizedBox(height: Dimensions.heightSize * 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                Strings.dontHaveAccount,
                style: CustomStyle.textStyle,
              ),
              GestureDetector(
                child: Text(
                  Strings.signUp,
                  style: TextStyle(
                      fontSize: Dimensions.defaultTextSize,
                      color: CustomColor.blueColor,
                      decoration: TextDecoration.underline),
                ),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => SignUpScreen()));
                },
              ),
            ],
          )
        ],
      )),
    );
  }

}
