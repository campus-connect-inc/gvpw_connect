import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

///All the generic sizes stored for ease access.
///passed in [Styles.textStyle] to maintain uniformity.
class FontSize {
  ///size -> 11.0
  static double textXs = 11.0;

  ///size -> 13.0
  static double textSm = 13.0;

  ///size -> 15.0
  static double textBase = 15.0;

  ///size -> 18.0
  static double textLg = 18.0;

  ///size -> 20.0
  static double textXl = 20.0;

  ///size -> 25.0
  static double text2Xl = 25.0;

  ///size -> 30.0
  static double text3Xl = 30.0;

  ///size -> 36.0
  static double text4Xl = 36.0;

  ///size -> 48.0
  static double text5Xl = 48.0;

  ///size -> 60.0
  static double text6Xl = 60.0;

  ///size -> 72.0
  static double text7Xl = 72.0;

  ///size -> 96.0
  static double text8Xl = 96.0;

  ///size -> 128.0
  static double text9Xl = 128.0;
}

class Styles {
  ///Pass in [FontSize] class variables in [fontSize] field.
  ///or pass in direct font size only if no other choice.
  static TextStyle textStyle(
      {double? fontSize,
      FontWeight? fontWeight,
      Color? color,
      double? letterSpacing,
      double? wordSpacing}) {
    return GoogleFonts.interTight(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
    );
  }
}
