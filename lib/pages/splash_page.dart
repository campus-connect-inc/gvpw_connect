// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:gvpw_connect/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:gvpw_connect/pages/surveys_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';
import '../providers/user_data_provider.dart';
import '../styles/styles.dart';
import '../utils/shared_preferences_service.dart';
import '../utils/util.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);
  static const id = "splash_page";

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool underMaintenance = false;
  Map status = {};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startRoutine();
  }

  Future<void> startRoutine() async{
    Future.delayed(const Duration(seconds: 0), () async {
      status = await AuthService.checkStatus();
      if(status["status"] == "online"){
        if (AuthService.isLoggedIn() && SharedPreferencesService.userOrg != null) {
          await Provider.of<UserDataProvider>(context, listen: false)
              .initialize();
          //push to surveys screen
          Provider.of<RouteNameProvider>(context, listen: false)
              .setCurrentRouteName(SurveysPage.id);
          Navigator.pushReplacementNamed(context, SurveysPage.id);
        } else {
          //set organisation
          await SharedPreferencesService.setUserOrganisation('gvpcew');
          //push to login page
          Provider.of<RouteNameProvider>(context, listen: false)
              .setCurrentRouteName(LoginPage.id);
          Navigator.pushReplacementNamed(context, LoginPage.id);
        }
      }else{
        // app under maintenance
        setState(() {
          underMaintenance = true;
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: ThemeProvider.primary,
      body: Stack(
        children: [
          Center(
            child: SvgPicture.asset(
              'assets/splash_screen/vector_0.svg',
              width: device.size.width,
              color: ThemeProvider.accent,
            ),
          ),
          Center(
            child: SvgPicture.asset(
              'assets/splash_screen/logo.svg',
              width: device.size.width*0.5,
            ),
          ),
          Positioned(
            bottom: 30,
            right: device.size.width * 0.15,
            left: device.size.width * 0.15,
            child: Column(
              children: [
                Center(
                  child: Image.asset("assets/splash_screen/gvcew_logo.png",height: 50,width: 50,),
                ),
                const SizedBox(height: 5,),
                Text(
                  "Connect for GVPCEW",
                  style: GoogleFonts.poppins(
                      color: ThemeProvider.accent,
                      fontSize: FontSize.textBase
                  ),
                ),
                const SizedBox(height: 10,),
                if(!underMaintenance) ...[
                  Lottie.asset(
                    'assets/animations/Loading Bar.json',
                    frameRate: FrameRate(60.0),
                  ),
                ] else ...[
                  Util.label("Maintenance underway ⚒️",color: Colors.white,fontSize: FontSize.textXl),
                  const SizedBox(height: 10,),
                  Util.label("Estimated time : ${status["tto"] ?? "unknown"}")
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
