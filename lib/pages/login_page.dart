// ignore_for_file: use_build_context_synchronously, deprecated_member_use
import 'package:gvpw_connect/pages/password_reset_page.dart';
import 'package:gvpw_connect/pages/surveys_page.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gvpw_connect/utils/auth_service.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../styles/styles.dart';
import '../utils/util.dart';
import 'otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const id = "login_page";
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isProcessing = false;
  bool showPassword = true;

  @override
  void initState() {
    super.initState();
    AuthService.isLoggedIn()
        ? Navigator.popAndPushNamed(context, SurveysPage.id)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final device = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: ThemeProvider.primary,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            //Login screen top background decoration vector.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                "assets/login_page/loginScreenDec.svg",
                color: ThemeProvider.secondary,
                width: device.size.width,
              ),
            ),

            //login screen logo
            Positioned(
              top: device.size.height * 0.07,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                "assets/login_page/logo.svg",
                height: 150,
                width: 150,
              ),
            ),

            //Main content
            Positioned(
              bottom: device.size.height * 0.17,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      cursorColor: ThemeProvider.secondary,
                      style: Styles.textStyle(
                          color: ThemeProvider.secondary,
                          fontWeight: FontWeight.w600),
                      controller: emailController,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        hintText: "Email",
                        hintStyle: Styles.textStyle(
                            color: ThemeProvider.secondary,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ThemeProvider.secondary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(
                          Icons.email,
                          color: ThemeProvider.secondary,
                          size: 25,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextField(
                      cursorColor: ThemeProvider.secondary,
                      style: Styles.textStyle(
                          color: ThemeProvider.secondary,
                          fontWeight: FontWeight.w600),
                      obscureText: showPassword,
                      controller: passwordController,
                      keyboardType: TextInputType.text,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        hintText: "Password",
                        hintStyle: Styles.textStyle(
                            color: ThemeProvider.secondary,
                            fontWeight: FontWeight.w600),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: ThemeProvider.secondary),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: Icon(
                            Ionicons.key_outline,
                            color: ThemeProvider.secondary,
                            size: 25,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                            child: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: ThemeProvider.secondary,
                              size: 25,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeProvider.secondary,
                                shadowColor: Colors.black45,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              onPressed: !isProcessing ? () async {
                                if (emailController.text.isEmpty ||
                                    passwordController.text.isEmpty) {
                                  Util.toast("Please fill in all fields");
                                } else {
                                  setState(() {
                                    isProcessing = true;
                                  });
                                  try {
                                    //this ensures the user is not getting logged in and we get to use the user uid and other data.
                                    UserCredential userCredential =
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );
                                    FirebaseAuth.instance.signOut();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => OtpPage(
                                              userCred: userCredential,
                                              password:
                                              passwordController.text,
                                            )));
                                  } on FirebaseAuthException catch (e) {
                                    Util.toast(e.code);
                                  }
                                  setState(() {
                                    isProcessing = false;
                                  });
                                }
                              } : null,
                              child: !isProcessing
                                  ? Text("Login",
                                  style: Styles.textStyle(
                                      color: ThemeProvider.accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize.textBase + 1))
                                  : SpinKitCircle(
                                color: ThemeProvider.accent,
                                size: 25,
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        //push forgot password page.
                        Navigator.pushNamed(context, PasswordResetPage.id);
                      },
                      child: Text("Forgot Password?",
                          style: Styles.textStyle(
                              color: ThemeProvider.accent,
                              fontWeight: FontWeight.w500,
                              fontSize: FontSize.textSm + 1)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}