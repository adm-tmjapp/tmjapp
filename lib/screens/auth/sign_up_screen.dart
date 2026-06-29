import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tmjapp/repository/auth_repository.dart';
import 'package:tmjapp/screens/dashboard_screen.dart';

import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/custom_style.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/screens/auth/personal_information_screen.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:tmjapp/widgets/profile_photo_bottom_sheet.dart';
import 'package:tmjapp/widgets/validate_phone_bottom_sheet.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

enum TypeData { email, password, name, lastName }

class _SignUpScreenState extends State<SignUpScreen> {
  Future<void> openProfilePhotoBottomSheet(String token, String userId) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => ProfilePhotoBottomSheet(
        onImageSelected: (file) {
          // Salve a imagem do perfil ou faça o tratamento necessário
        },
        token: token,
        userId: userId,
      ),
    );
  }

  Future<void> openValidatePhoneBottomSheet(
      String token, String userId, String phone) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => ValidatePhoneBottomSheet(
        token: token,
        userId: userId,
        phone: phone,
      ),
    );
  }

  String? selectedGender;
  final List<String> genderOptions = [
    'Masculino',
    'Feminino',
    'Não-binário',
    'Transgênero',
    'Agênero',
    'Gênero fluido',
    'Outro',
    'Prefiro não dizer'
  ];
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String selectedCounty = 'Brasil';

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  CountryCode? selectedCountryCode = CountryCode.fromDialCode("+55");
  final GlobalKey<FormFieldState> _formKeyEmail = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _formKeyPassword =
      GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _formKeyPhone = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _formKeyName = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _formKeyLastName =
      GlobalKey<FormFieldState>();
  AuthRepository repository = AuthRepository();

  bool _toggleVisibility = true;
  bool checkTermsConditions = false;

  var maskFormatterNumber = MaskTextInputFormatter(
      mask: '(##) #####-#### -####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  void initState() {
    super.initState();
    numberController.text = '';
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   openValidatePhoneBottomSheet("", "", "+5581999999999");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(children: [
              Image.asset('assets/bg.png',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3),
              DraggableScrollableSheet(
                  builder: (context, scrollController) {
                    return Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(Dimensions.radius * 3),
                                topRight:
                                    Radius.circular(Dimensions.radius * 3))),
                        child: SingleChildScrollView(
                            child: signUpWidget(context),
                            controller: scrollController));
                  },
                  initialChildSize: 0.77,
                  minChildSize: 0.77,
                  maxChildSize: 1)
            ])));
  }

  signUpWidget(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(
            left: Dimensions.marginSize,
            right: Dimensions.marginSize,
            top: Dimensions.heightSize * 3),
        child: (Column(children: [
          Text(Strings.signUpWithMobileNumber,
              style: GoogleFonts.roboto(
                  fontSize: Dimensions.extraLargeTextSize,
                  fontWeight: FontWeight.bold,
                  color: CustomColor.primaryColor)),
          const SizedBox(height: Dimensions.heightSize * 3),
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Form(
                  key: formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Strings.firstName,
                            style: GoogleFonts.roboto(
                                fontSize: Dimensions.defaultTextSize,
                                color: CustomColor.primaryColor)),
                        const SizedBox(height: Dimensions.heightSize * 0.5),
                        TextFormField(
                            key: _formKeyName,
                            style: CustomStyle.textStyle,
                            controller: firstNameController,
                            keyboardType: TextInputType.name,
                            validator: (String? value) {
                              if (value != null && value.isEmpty) {
                                return Strings.pleaseFillOutTheField;
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                                hintText: Strings.demoFirstName,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                labelStyle: CustomStyle.textStyle,
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: CustomStyle.hintTextStyle,
                                focusedBorder: CustomStyle.focusBorder,
                                enabledBorder: CustomStyle.focusErrorBorder,
                                focusedErrorBorder:
                                    CustomStyle.focusErrorBorder,
                                errorBorder: CustomStyle.focusErrorBorder)),
                        const SizedBox(height: Dimensions.heightSize),
                        Text(Strings.lastName,
                            style: GoogleFonts.roboto(
                                fontSize: Dimensions.defaultTextSize,
                                color: CustomColor.primaryColor)),
                        const SizedBox(height: Dimensions.heightSize * 0.5),
                        TextFormField(
                            key: _formKeyLastName,
                            style: CustomStyle.textStyle,
                            controller: lastNameController,
                            keyboardType: TextInputType.name,
                            validator: (String? value) {
                              if (value != null && value.isEmpty) {
                                return Strings.pleaseFillOutTheField;
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                                hintText: Strings.demoLastName,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                labelStyle: CustomStyle.textStyle,
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: CustomStyle.hintTextStyle,
                                focusedBorder: CustomStyle.focusBorder,
                                enabledBorder: CustomStyle.focusErrorBorder,
                                focusedErrorBorder:
                                    CustomStyle.focusErrorBorder,
                                errorBorder: CustomStyle.focusErrorBorder)),
                        const SizedBox(height: Dimensions.heightSize),
                        Text('Gênero',
                            style: GoogleFonts.roboto(
                                fontSize: Dimensions.defaultTextSize,
                                color: CustomColor.primaryColor)),
                        const SizedBox(height: Dimensions.heightSize * 0.5),
                        DropdownButtonFormField<String>(
                          value: selectedGender,
                          decoration: InputDecoration(
                            hintText: 'Selecione o gênero',
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            labelStyle: CustomStyle.textStyle,
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: CustomStyle.hintTextStyle,
                            focusedBorder: CustomStyle.focusBorder,
                            enabledBorder: CustomStyle.focusErrorBorder,
                            focusedErrorBorder: CustomStyle.focusErrorBorder,
                            errorBorder: CustomStyle.focusErrorBorder,
                          ),
                          items: genderOptions.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender, style: CustomStyle.textStyle),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGender = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, selecione o gênero';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: Dimensions.heightSize),
                        Text(Strings.emailAddress,
                            style: GoogleFonts.roboto(
                                fontSize: Dimensions.defaultTextSize,
                                color: CustomColor.primaryColor)),
                        const SizedBox(height: Dimensions.heightSize * 0.5),
                        TextFormField(
                            key: _formKeyEmail,
                            style: CustomStyle.textStyle,
                            controller: emailController,
                            keyboardType: TextInputType.name,
                            validator: (String? value) {
                              validateEmailInput(TypeData.email, value);
                            },
                            decoration: InputDecoration(
                                hintText: Strings.emailAddress,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                labelStyle: CustomStyle.textStyle,
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: CustomStyle.hintTextStyle,
                                focusedBorder: CustomStyle.focusBorder,
                                enabledBorder: CustomStyle.focusErrorBorder,
                                focusedErrorBorder:
                                    CustomStyle.focusErrorBorder,
                                errorBorder: CustomStyle.focusErrorBorder)),
                        const SizedBox(height: Dimensions.heightSize),
                        Text(Strings.phone,
                            style: GoogleFonts.roboto(
                                fontSize: Dimensions.defaultTextSize,
                                color: CustomColor.primaryColor)),
                        const SizedBox(height: Dimensions.heightSize * 0.5),
                        Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.1)),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(Dimensions.radius * 0.5))),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CountryCodePicker(
                                      onChanged: (CountryCode countryCode) {
                                        setState(() {
                                          selectedCountryCode = countryCode;
                                          selectedCounty =
                                              countryCode.name ?? "";
                                        });
                                      },
                                      initialSelection:
                                          selectedCountryCode?.code,
                                      favorite: const [
                                        '+1',
                                        '+55'
                                      ], // Add your favorite country codes here
                                      showCountryOnly:
                                          false, // Set to true to show only country names
                                      showOnlyCountryWhenClosed:
                                          false, // Set to true to show only the selected country when closed
                                      alignLeft:
                                          false, // Set to true for left alignment
                                      padding: EdgeInsets
                                          .zero, // Adjust padding as needed
                                      textStyle: CustomStyle
                                          .textStyle // Customize text style
                                      ),
                                  SizedBox(
                                      height: 50.0,
                                      width: MediaQuery.of(context).size.width /
                                          1.8,
                                      child: TextFormField(
                                          key: _formKeyPhone,
                                          inputFormatters: [
                                            maskFormatterNumber
                                          ],
                                          style: CustomStyle.textStyle,
                                          controller: numberController,
                                          keyboardType: TextInputType.number,
                                          validator: (String? value) {
                                            if (value!.isEmpty) {
                                              return Strings
                                                  .pleaseFillOutTheField;
                                            } else {
                                              return null;
                                            }
                                          },
                                          decoration: InputDecoration(
                                              hintText: Strings.phone,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 10.0),
                                              labelStyle: CustomStyle.textStyle,
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintStyle: CustomStyle.textStyle,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedErrorBorder:
                                                  InputBorder.none,
                                              errorBorder: InputBorder.none)))
                                ])),
                        const SizedBox(height: Dimensions.heightSize),
                        Text(Strings.password,
                            style: GoogleFonts.roboto(
                                fontSize: Dimensions.defaultTextSize,
                                color: CustomColor.primaryColor)),
                        const SizedBox(height: Dimensions.heightSize * 0.5),
                        TextFormField(
                            key: _formKeyPassword,
                            style: CustomStyle.textStyle,
                            controller: passwordController,
                            validator: (String? value) {
                              if (value != null && value.isEmpty) {
                                return Strings.pleaseFillOutTheField;
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                                hintText: Strings.demoPassword,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                labelStyle: CustomStyle.textStyle,
                                focusedBorder: CustomStyle.focusBorder,
                                enabledBorder: CustomStyle.focusErrorBorder,
                                focusedErrorBorder:
                                    CustomStyle.focusErrorBorder,
                                errorBorder: CustomStyle.focusErrorBorder,
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: CustomStyle.hintTextStyle,
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _toggleVisibility = !_toggleVisibility;
                                      });
                                    },
                                    icon: _toggleVisibility
                                        ? Icon(Icons.visibility_off,
                                            color:
                                                Colors.black.withOpacity(0.2))
                                        : Icon(Icons.visibility,
                                            color: Colors.black
                                                .withOpacity(0.2)))),
                            obscureText: _toggleVisibility)
                      ]))),
          const SizedBox(height: Dimensions.heightSize),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(children: [
                  Text(Strings.agree, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 3),
                  GestureDetector(
                      onTap: () {},
                      child: Text(Strings.privacyPolicy.toLowerCase(),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.red))),
                  const SizedBox(width: 3)
                ])
              ]),
          const SizedBox(height: Dimensions.heightSize * 2),
          GestureDetector(
              child: Container(
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      color: CustomColor.primaryColor,
                      borderRadius: BorderRadius.all(
                          Radius.circular(Dimensions.radius * 0.5))),
                  child: Center(
                      child: Text(Strings.next.toUpperCase(),
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: Dimensions.largeTextSize,
                              fontWeight: FontWeight.bold)))),
              onTap: () async {
                if (_formKeyName.currentState!.validate() &&
                    _formKeyLastName.currentState!.validate() &&
                    _formKeyEmail.currentState!.validate() &&
                    _formKeyPhone.currentState!.validate() &&
                    _formKeyPassword.currentState!.validate()) {
                  if (checkTermsConditions) {
                    var response = await repository.signUp(
                        numberController.text,
                        firstNameController.text,
                        lastNameController.text,
                        genderOptions
                            .indexOf(selectedGender ?? 'Masculino')
                            .toString(),
                        emailController.text,
                        passwordController.text);
                    if (response != null) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          title: Text('Usuário criado com sucesso!'),
                          content: Text(
                              'Cadastro concluído. Faça login para testar o primeiro acesso.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).popUntil(
                                  (route) => route.isFirst,
                                );
                              },
                              child: Text('Ir para login'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                  title: Text(Strings.error),
                                  content: Text(Strings.invalidEmailPassword),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'))
                                  ]));
                    }
                  } else {
                    showTermsConditions();
                  }
                } else {}
              }),
          const SizedBox(height: Dimensions.heightSize * 2),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(Strings.alreadyHaveAnAccount,
                    style: CustomStyle.textStyle),
                GestureDetector(
                    child: Text(Strings.signIn,
                        style: TextStyle(
                            fontSize: Dimensions.defaultTextSize,
                            color: CustomColor.blueColor,
                            decoration: TextDecoration.underline)),
                    onTap: () {
                      Navigator.of(context).pop();
                    })
              ])
        ])));
  }

  Future<bool> showTermsConditions() async {
    return (await showDialog(
            context: context,
            builder: (context) => Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: CustomColor.primaryColor,
                child: Stack(children: [
                  Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.defaultPaddingSize * 2,
                          bottom: Dimensions.defaultPaddingSize * 2),
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: AlertDialog(
                              content: Stack(children: [
                            Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 45,
                                child: SingleChildScrollView(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      const SizedBox(
                                          height: Dimensions.heightSize * 2),
                                      Text(Strings.ourPolicyTerms,
                                          style: GoogleFonts.roboto(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              fontSize:
                                                  Dimensions.largeTextSize,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(
                                          height: Dimensions.heightSize),
                                      Text(
                                          'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old',
                                          style: CustomStyle.textStyle),
                                      const SizedBox(
                                          height: Dimensions.heightSize),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('•',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        CustomColor.accentColor,
                                                    fontSize: Dimensions
                                                        .extraLargeTextSize)),
                                            const SizedBox(width: 5.0),
                                            Expanded(
                                                child: Text(
                                                    'simply random text. It has roots in a piece of classical Latin literature ',
                                                    style:
                                                        CustomStyle.textStyle))
                                          ]),
                                      const SizedBox(
                                          height: Dimensions.heightSize),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('•',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        CustomColor.accentColor,
                                                    fontSize: Dimensions
                                                        .extraLargeTextSize)),
                                            const SizedBox(width: 5.0),
                                            Expanded(
                                                child: Text(
                                                    'Distracted by the readable content of a page when looking at its layout.',
                                                    style:
                                                        CustomStyle.textStyle))
                                          ]),
                                      const SizedBox(
                                          height: Dimensions.heightSize),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text('•',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        CustomColor.accentColor,
                                                    fontSize: Dimensions
                                                        .extraLargeTextSize)),
                                            const SizedBox(width: 5.0),
                                            Expanded(
                                                child: Text(
                                                    'Available, but the majority have suffered alteration',
                                                    style:
                                                        CustomStyle.textStyle))
                                          ]),
                                      const SizedBox(
                                          height: Dimensions.heightSize * 2),
                                      Text('When do we contact information ?',
                                          style: GoogleFonts.roboto(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              fontSize:
                                                  Dimensions.largeTextSize,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(
                                          height: Dimensions.heightSize),
                                      Text(
                                          'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old',
                                          style: CustomStyle.textStyle),
                                      const SizedBox(
                                          height: Dimensions.heightSize * 2),
                                      Text('Do we use cookies ?',
                                          style: GoogleFonts.roboto(
                                              color:
                                                  Colors.black.withOpacity(0.7),
                                              fontSize:
                                                  Dimensions.largeTextSize,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(
                                          height: Dimensions.heightSize),
                                      Text(
                                          'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old',
                                          style: CustomStyle.textStyle)
                                    ]))),
                            Positioned(
                                bottom: 0,
                                child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                  child: Container(
                                                      height: 35.0,
                                                      width: 100.0,
                                                      decoration: BoxDecoration(
                                                          color: CustomColor
                                                              .yellowLightColor,
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                  Radius.circular(
                                                                      5.0))),
                                                      child: Center(
                                                          child: Text(
                                                              Strings.decline,
                                                              style: GoogleFonts.roboto(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize:
                                                                      Dimensions
                                                                          .defaultTextSize)))),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  }),
                                              const SizedBox(width: 10.0),
                                              GestureDetector(
                                                  child: Container(
                                                      height: 35.0,
                                                      width: 100.0,
                                                      decoration: BoxDecoration(
                                                          color: CustomColor
                                                              .accentColor,
                                                          borderRadius:
                                                              const BorderRadius.all(
                                                                  Radius.circular(
                                                                      5.0))),
                                                      child: Center(
                                                          child: Text(
                                                              Strings.agree,
                                                              style: GoogleFonts.roboto(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      Dimensions
                                                                          .defaultTextSize)))),
                                                  onTap: () {
                                                    setState(() {
                                                      checkTermsConditions =
                                                          true;
                                                    });
                                                    Navigator.pop(context);
                                                    /*Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) =>
                                                                                  PersonalInformationScreen() //PersonalInformationScreen(),
                                                                          )
                                                                      );*/
                                                  })
                                            ]))))
                          ]))))
                ])))) ??
        false;
  }

  String? validateEmailInput(TypeData type, String? value) {
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
