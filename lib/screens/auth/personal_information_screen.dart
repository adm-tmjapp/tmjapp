import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tmjapp/screens/dashboard_screen.dart';

import '../../utils/colors.dart';
import '../../utils/custom_style.dart';
import '../../utils/dimensions.dart';
import '../../utils/strings.dart';
import 'otp/phone_verification_screen.dart';

class PersonalInformationScreen extends StatefulWidget
{
    @override
    _PersonalInformationScreenState createState() =>
    _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen>
{
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    TextEditingController firstNameController = TextEditingController();

    @override
    Widget build(BuildContext context) 
    {
        return SafeArea(
            child: Scaffold(
                body: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                        children: [
                            Image.asset(
                                'assets/bg.png',
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height * 0.3
                            ),
                            DraggableScrollableSheet(
                                builder: (context, scrollController)
                                {
                                    return Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(Dimensions.radius * 3),
                                                topRight: Radius.circular(Dimensions.radius * 3)
                                            )
                                        ),
                                        child: SingleChildScrollView(
                                            child: personalInformationWidget(context),
                                            controller: scrollController
                                        )
                                    );
                                },
                                initialChildSize: 0.77,
                                minChildSize: 0.77,
                                maxChildSize: 1
                            )
                        ]
                    )
                )
            )
        );
    }

    personalInformationWidget(BuildContext context) 
    {
        return Padding(
            padding: const EdgeInsets.only(
                left: Dimensions.marginSize,
                right: Dimensions.marginSize,
                top: Dimensions.heightSize * 3
            ),
            child: Column(
                children: [
                    Text(
                        Strings.personalInformation,
                        style: GoogleFonts.roboto(
                            fontSize: Dimensions.extraLargeTextSize,
                            fontWeight: FontWeight.bold,
                            color: CustomColor.primaryColor
                        )
                    ),
                    const SizedBox(height: Dimensions.heightSize * 3),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        child: Form(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Text(
                                        Strings.idCertificate,
                                        style: GoogleFonts.roboto(
                                            fontSize: Dimensions.defaultTextSize,
                                            color: CustomColor.primaryColor
                                        )
                                    ),
                                    const SizedBox(height: Dimensions.heightSize * 0.5),
                                    Container(
                                        height: 50,
                                        width: MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(
                                                color: Colors.black.withOpacity(0.1),
                                                style: BorderStyle.solid,
                                                width: 1
                                            )
                                        ),
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: Dimensions.marginSize * 0.5,
                                                right: Dimensions.marginSize * 0.5
                                            ),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    Text(
                                                        Strings.pictureRegistrationFront,
                                                        style: CustomStyle.textStyle
                                                    ),
                                                    GestureDetector(
                                                        child: Text(
                                                            Strings.upload.toUpperCase(),
                                                            style: GoogleFonts.roboto(
                                                                fontSize: Dimensions.largeTextSize,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.green
                                                            )
                                                        ),
                                                        onTap: ()
                                                        {
                                                            _openImageSourceOptions(context);
                                                        }
                                                    )
                                                ]
                                            )
                                        )
                                    ),
                                    const SizedBox(height: Dimensions.heightSize * 3),
                                    Text(
                                        Strings.idCertificate,
                                        style: GoogleFonts.roboto(
                                            fontSize: Dimensions.defaultTextSize,
                                            color: CustomColor.primaryColor
                                        )
                                    ),
                                    const SizedBox(height: Dimensions.heightSize * 0.5),
                                    Container(
                                        height: 50,
                                        width: MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(5.0),
                                            border: Border.all(
                                                color: Colors.black.withOpacity(0.1),
                                                style: BorderStyle.solid,
                                                width: 1
                                            )
                                        ),
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: Dimensions.marginSize * 0.5,
                                                right: Dimensions.marginSize * 0.5
                                            ),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    Text(
                                                        Strings.pictureRegistrationBack,
                                                        style: CustomStyle.textStyle
                                                    ),
                                                    GestureDetector(
                                                        child: Text(
                                                            Strings.upload.toUpperCase(),
                                                            style: GoogleFonts.roboto(
                                                                fontSize: Dimensions.largeTextSize,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.green
                                                            )
                                                        ),
                                                        onTap: ()
                                                        {
                                                            _openImageSourceOptions(context);
                                                        }
                                                    )
                                                ]
                                            )
                                        )
                                    ),
                                    const SizedBox(height: Dimensions.heightSize * 3),
                                    GestureDetector(
                                        child: Container(
                                            height: 50.0,
                                            width: MediaQuery.of(context).size.width,
                                            decoration: const BoxDecoration(
                                                color: CustomColor.primaryColor,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(Dimensions.radius * 0.5)
                                                )
                                            ),
                                            child: Center(
                                                child: Text(
                                                    Strings.registration.toUpperCase(),
                                                    style: GoogleFonts.roboto(
                                                        color: Colors.white,
                                                        fontSize: Dimensions.largeTextSize,
                                                        fontWeight: FontWeight.bold
                                                    )
                                                )
                                            )
                                        ),
                                        onTap: ()
                                        {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder:
                                                    (context) => DashboardScreen()
                                                )
                                            );
                                        }
                                    )
                                ]
                            )
                        )
                    )
                ]
            )
        );
    }

    Future<void> _openImageSourceOptions(BuildContext context) 
    {
        return showDialog(
            context: context,
            builder: (BuildContext context)
            {
                return AlertDialog(
                    content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                            GestureDetector(
                                child: Icon(Icons.camera_alt, size: 40.0, color: Colors.blue),
                                onTap: ()
                                {
                                    Navigator.of(context).pop();
                                    _chooseFromCamera();
                                }
                            ),
                            GestureDetector(
                                child: Icon(Icons.photo, size: 40.0, color: Colors.green),
                                onTap: ()
                                {
                                    Navigator.of(context).pop();
                                    _chooseFromGallery();
                                }
                            )
                        ]
                    )
                );
            }
        );
    }

    File? fileFromDocument;

    void _chooseFromGallery() async
    {
        // Use the `ImagePicker` plugin to pick an image from the gallery
        final XFile? pickedFile = await ImagePicker().pickImage(
            source: ImageSource.gallery,
            imageQuality: 100,
            maxHeight: 250,
            maxWidth: 250
        );

        if (pickedFile == null) 
        {
            Fluttertoast.showToast(msg: 'No File Selected');
        }
        else 
        {
            // Convert the `XFile` to a `File` object
            final File fileFromDocument = File(pickedFile.path);

            setState(()
                {
                    // Use the `fileFromDocument` variable as needed
                    print('for doc image');
                }
            );
        }
    }

    void _chooseFromCamera() async
    {
        print('open camera');
        // Use the `ImagePicker` plugin to capture an image from the camera
        final XFile? pickedFile = await ImagePicker().pickImage(
            source: ImageSource.camera,
            imageQuality: 50,
            maxHeight: 250,
            maxWidth: 250
        );

        print('picked camera');
        if (pickedFile == null) 
        {
            Fluttertoast.showToast(msg: 'No Capture Image');
        }
        else 
        {
            // Convert the `XFile` to a `File` object
            final File fileFromDocument = File(pickedFile.path);

            setState(()
                {
                    // Use the `fileFromDocument` variable as needed
                }
            );
        }
    }
}
