import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class ThemeProvider {
  //------------main palette-------------------//
  static final primary = HexColor("1B262C");
  static final secondary = HexColor("0F4C75");
  static final tertiary = HexColor("3282B8");
  static final accent = HexColor("BBE1FA");

  //splash colors and other actions
  static const splashPrimary = Colors.blue;
  //font
  static const fontPrimary = Colors.white;
  static const fontSecondary = Colors.blue;
  static const fontAccent = Colors.blueAccent;
  //icons
  static const iconPrimary = Colors.white;
  static const iconSecondary = Colors.blue;
  static const iconAccent = Colors.blueAccent;
  //page wise svg background colors
  //admin console page
  static final adminConsoleBackground = HexColor("151515");
  static final adminConsoleEllipses = HexColor("00C2FF");
  // common alert box
  static final commonAlertBox = primary;

//------------another palette(black,brown,beige)-------------------//
// static final primary = HexColor("000000");
// static final secondary = HexColor("282A3A");
// static final tertiary = HexColor("735F32");
// static final accent = HexColor("C69749");
//
// //splash colors and other actions
// static const splashPrimary = Colors.blue;
// //font
// static const fontPrimary = Colors.white;
// static const fontSecondary = Colors.orange;
// static const fontAccent = Colors.orangeAccent;
// //icons
// static const iconPrimary = Colors.white;
// static const iconSecondary = Colors.orange;
// static const iconAccent = Colors.orangeAccent;
// //page wise svg background colors
// //admin console page
// static final adminConsoleBackground = HexColor("282A3A").withOpacity(0.5);
// static final adminConsoleEllipses = HexColor("282A3A");
// //common alert box
// static final commonAlertBox = secondary;
}