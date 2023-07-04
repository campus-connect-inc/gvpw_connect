// ignore_for_file: deprecated_member_use
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:gvpw_connect/utils/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../styles/styles.dart';
import '../utils/util.dart';

class SurveySubmitSuccessPage extends StatefulWidget {
  const SurveySubmitSuccessPage({Key? key}) : super(key: key);
  static const id = "submit_success_screen";

  @override
  State<SurveySubmitSuccessPage> createState() =>
      _SurveySubmitSuccessPageState();
}

class _SurveySubmitSuccessPageState extends State<SurveySubmitSuccessPage> {
  @override
  void initState() {
    super.initState();
    AudioService.playSuccessSound();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Util.commonAppBar(context, name: '',
          backgroundColor: ThemeProvider.accent,
        leadingIconColor: ThemeProvider.primary
      ),
      backgroundColor: ThemeProvider.primary,
      body: Stack(
        children: [
          Positioned(
            top: -50,
            right: 0,
            left: 0,
            child: SvgPicture.asset("assets/submit_success_screen/top_bg.svg",color: ThemeProvider.accent),
          ),
          Positioned(
            top: 60,
            left: 25,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Your response has been recorded.",
                    style: Styles.textStyle(
                      color: ThemeProvider.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: FontSize.textXl + 2,
                    )),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 40,
              ),
              Lottie.asset(
                "assets/animations/successfully-done.json",
                repeat: false,
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            left: 25,
            right: 25,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Text("You can head back to home now.",
                      style: Styles.textStyle(
                        color: ThemeProvider.fontPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: FontSize.textLg,
                      )),
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          backgroundColor: ThemeProvider.secondary,
                          shadowColor: Colors.black45,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 3),
                          child: Text(
                            "Home",
                            style: Styles.textStyle(
                                color: ThemeProvider.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: FontSize.textBase),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}