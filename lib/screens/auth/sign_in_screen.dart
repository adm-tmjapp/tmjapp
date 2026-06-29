import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmjapp/app/router/app_router.dart';
import 'package:tmjapp/repository/auth_repository.dart';
import 'package:tmjapp/repository/location_app.dart';
import 'package:tmjapp/screens/auth/check_phone_screen.dart';
import 'package:tmjapp/screens/auth/sign_up_screen.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:tmjapp/utils/custom_style.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/widgets/profile_photo_bottom_sheet.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

enum TypeData { email, password }

class _SignInScreenState extends State<SignInScreen> {
  SharedPreferences? prefs;
  LocationApp locationApp = LocationApp();
  AuthRepository repository = AuthRepository();
  CountryCode? selectedCountryCode = CountryCode.fromDialCode("+55");
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormFieldState> _formKeyEmail = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _formKeyPassword =
      GlobalKey<FormFieldState>();

  bool _toggleVisibility = true;
  bool checkRememberMe = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    checkData();
  }

  Future<void> checkData() async {
    await locationApp.requestPermissionLocation();
    prefs = await SharedPreferences.getInstance();
    emailController.text = '';
    String? email = prefs?.getString(Strings.prefEmail);
    String? password = prefs?.getString(Strings.prefPassword);

    if (email != null && email.isNotEmpty) {
      setState(() {
        checkRememberMe = true;
        emailController.text = email;
      });
    }

    if (password != null && password.isNotEmpty) {
      setState(() {
        checkRememberMe = true;
        passwordController.text = password;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
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
              padding: const EdgeInsets.only(bottom: 8.0),
              child: inputData(TypeData.email)),
          inputData(TypeData.password),
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
                  Strings.loginforPhone,
                  style: TextStyle(
                      fontSize: Dimensions.defaultTextSize,
                      color: CustomColor.blueColor,
                      decoration: TextDecoration.underline),
                ),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CheckPhoneSceen()));
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
              validateData();
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

  Widget inputData(TypeData type) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.1)),
          borderRadius:
              const BorderRadius.all(Radius.circular(Dimensions.radius * 0.5))),
      child: SizedBox(
        height: 50.0,
        width: MediaQuery.of(context).size.width / 1.8,
        child: TextFormField(
          key: type == TypeData.email ? _formKeyEmail : _formKeyPassword,
          style: CustomStyle.textStyle,
          controller:
              type == TypeData.email ? emailController : passwordController,
          keyboardType: type == TypeData.email
              ? TextInputType.emailAddress
              : TextInputType.visiblePassword,
          validator: (String? value) {
            return validateInput(type, value);
          },
          decoration: InputDecoration(
            icon: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: type == TypeData.email
                  ? const Icon(Icons.email)
                  : const Icon(Icons.lock),
            ),
            errorStyle: const TextStyle(color: Colors.red),
            errorText: _hasError ? Strings.invalidEmailPassword : null,
            hintText: type == TypeData.email ? Strings.email : Strings.password,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
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
    );
  }

  Future<void> validateData() async {
    if (_formKeyEmail.currentState?.validate() ?? false) {
      if (checkRememberMe) {
        await prefs?.setString(Strings.prefEmail, emailController.text);
        await prefs?.setString(Strings.prefPassword, passwordController.text);
      } else {
        await prefs?.remove(Strings.prefEmail);
        await prefs?.remove(Strings.prefPassword);
      }
      var response =
          await repository.login(emailController.text, passwordController.text);
      if (response != null) {
        Navigator.pushNamed(context, AppRoutes.dashboard);
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.error)),
      );
    }
  }

  String? validateInput(TypeData type, String? value) {
    if (value != null && value.isEmpty) {
      return Strings.pleaseFillOutTheField;
    } else {
      if (type == TypeData.email) {
        if (value!.contains("@") && value.contains(".com")) {
          return null;
        } else {
          return Strings.invalidEmail;
        }
      }
    }
    return null;
  }
}
