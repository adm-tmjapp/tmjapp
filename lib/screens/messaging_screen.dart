import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tmjapp/utils/colors.dart';
import 'package:tmjapp/utils/custom_style.dart';
import 'package:tmjapp/utils/dimensions.dart';
import 'package:tmjapp/utils/strings.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tmjapp/data_model/message.dart';

class MessagingScreen extends StatefulWidget {
  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  TextEditingController messageController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFBFB),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            profileWidget(context),
            messagingWidget(context),
            typeMessageWidget(context),
          ],
        ),
      ),
    );
  }

  Widget profileWidget(BuildContext context) {
    return Positioned(
      top: 150.0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -40,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/driver.png',
                          width: 80,
                          height: 80,
                        ),
                        Text(
                          'Justin Bieber',
                          style: GoogleFonts.roboto(
                            color: CustomColor.redDarkColor,
                            fontSize: Dimensions.largeTextSize,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: Dimensions.heightSize * 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  messagingWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: Dimensions.marginSize,
          right: Dimensions.marginSize,
          top: 230.0,
          bottom: 100),
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView.builder(
            itemCount: MessageList.list().length,
            itemBuilder: (context, index) {
              Message message = MessageList.list()[index];
              return Padding(
                  padding: const EdgeInsets.only(
                    bottom: Dimensions.heightSize,
                  ),
                  child: message.type != 'sender'
                      ? Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: Dimensions.marginSize,
                                  left: Dimensions.marginSize),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFFFAE9E9),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30.0),
                                        bottomLeft: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0))),
                                child: Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: Dimensions.marginSize,
                                        right: Dimensions.marginSize,
                                        top: Dimensions.heightSize,
                                        bottom: Dimensions.heightSize),
                                    child: Text(
                                      message.text ?? "",
                                      style: GoogleFonts.roboto(
                                        color: CustomColor.greyColor,
                                        fontSize: Dimensions.defaultTextSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: Dimensions.marginSize),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                child: Text(
                                  'seen message',
                                  style: GoogleFonts.roboto(
                                    color: Colors.black.withOpacity(0.3),
                                    fontSize: Dimensions.extraSmallTextSize,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: ClipRRect(
                                    child: Image.asset(
                                      'assets/user.png',
                                      height: 20,
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.name ?? "",
                                      style: GoogleFonts.roboto(
                                        color: CustomColor.redDarkColor,
                                        fontSize: Dimensions.smallTextSize,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                    Text(
                                      message.time ?? "",
                                      style: GoogleFonts.roboto(
                                        color: Colors.black.withOpacity(0.3),
                                        fontSize: Dimensions.extraSmallTextSize,
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: Dimensions.marginSize,
                                  right: Dimensions.marginSize),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Color(0xFFFDF4EC),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30.0),
                                        bottomLeft: Radius.circular(30.0),
                                        bottomRight: Radius.circular(30.0))),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: Dimensions.marginSize,
                                        right: Dimensions.marginSize,
                                        top: Dimensions.heightSize,
                                        bottom: Dimensions.heightSize),
                                    child: Text(
                                      message.text ?? "",
                                      style: GoogleFonts.roboto(
                                        color: CustomColor.greyColor,
                                        fontSize: Dimensions.defaultTextSize,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ));
            }),
      ),
    );
  }

  Widget typeMessageWidget(BuildContext context) {
    return Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.marginSize),
          child: Container(
            height: 60,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: CustomColor.primaryColor,
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: Dimensions.marginSize),
                  child: Row(
                    children: [
                      Form(
                          key: formKey,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextFormField(
                              style: CustomStyle.textStyle,
                              controller: messageController,
                              keyboardType: TextInputType.name,
                              validator: (String? value) {
                                if (value != null && value.isEmpty) {
                                  return Strings.typeSomething;
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                hintText: Strings.typeMessage,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                labelStyle: CustomStyle.textStyle,
                                filled: true,
                                fillColor: Colors.white,
                                hintStyle: CustomStyle.textStyle,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.send,
                      color: CustomColor.accentColor,
                      size: 25,
                    ),
                    onPressed: () {})
              ],
            ),
          ),
        ));
  }
}
