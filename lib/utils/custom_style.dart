import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'dimensions.dart';

class CustomStyle {
  static var textStyle = GoogleFonts.roboto(
      color: CustomColor.greyColor,
      fontSize: Dimensions.defaultTextSize
  );

  static var hintTextStyle = GoogleFonts.roboto(
      color: Colors.grey.withOpacity(0.5),
      fontSize: Dimensions.defaultTextSize
  );

  static var listStyle = GoogleFonts.roboto(
      color: CustomColor.redDarkColor,
      fontSize: Dimensions.defaultTextSize
  );

  static var defaultStyle = GoogleFonts.roboto(
      color: Colors.black,
      fontSize: Dimensions.largeTextSize
  );

  static var focusBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.1), width: 2.0),
  );

  static var focusErrorBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(5.0)),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.1), width: 1.0),
  );

  static var searchBox = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide(color: Colors.black.withOpacity(0.1), width: 1.0),
  );
}