import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:gvpw_connect/styles/styles.dart';
import 'package:gvpw_connect/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';

import '../utils/util.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({Key? key}) : super(key: key);
  static const id = 'password_reset_page';
  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final emailController = TextEditingController();
  bool emailSent = false;
  String errorCode = '';
  bool isProcessing = false;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoggedIn = AuthService.isLoggedIn();
    });
    if(isLoggedIn){
      emailController.setText(AuthService.getUserEmail()!);
    }
  }



  @override
  Widget build(BuildContext context) {
    final device = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ThemeProvider.primary,
      appBar: Util.commonAppBar(context, name: "",backgroundColor: ThemeProvider.secondary),
      body: Stack(
        children: [
          Positioned(
            top: - 60,
            left: 0,
            right: 0,
            child: SvgPicture.asset(
              "assets/login_page/loginScreenDec.svg",
              width: device.size.width,
            ),
          ),
          Positioned(
            top: 15,
            left: 25,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Util.label(!isLoggedIn ? "Forgot password?" : "Reset Password",color: ThemeProvider.accent,fontSize: FontSize.text3Xl,fontWeight: FontWeight.w600),
                const SizedBox(height: 25,),
                if(!isLoggedIn) ...[
                  Util.label("We get it managing passwords is a hassle 😓.",color: ThemeProvider.fontPrimary.withOpacity(0.8),fontSize: FontSize.textBase,),
                  const SizedBox(height: 10,),
                  Util.label("Enter your login email and a password reset email will be sent to your inbox 😄🙌",color: ThemeProvider.fontPrimary,fontSize: FontSize.textBase,)
                ]else ...[
                  Util.label("A password reset email will be sent to your inbox upon pressing on 'send link'",color: ThemeProvider.fontPrimary,fontSize: FontSize.textLg,)
                ]
              ],
            ),
          ),
          Positioned(
            top: 240,
            left: 25,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Util.label(!isLoggedIn ? "Login email" : "To Email",fontSize: FontSize.text3Xl,color: ThemeProvider.fontSecondary,fontWeight: FontWeight.w600),
                const SizedBox(height: 40,),
                TextField(
                  readOnly: isLoggedIn,
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
                    fillColor: ThemeProvider.accent,
                    filled: true,
                    prefixIcon: Icon(
                      Icons.email,
                      color: ThemeProvider.secondary,
                      size: 25,
                    ),
                  ),
                ),
                if(errorCode.isNotEmpty) ...[
                  const SizedBox(height: 40,),
                  Util.label(errorCode == 'user-not-found' ? 'User does not exist for the given email.' : errorCode , color: ThemeProvider.accent,fontSize: FontSize.textLg,maxLines: 3,overflow: TextOverflow.ellipsis),
                ],
                if(emailSent) ...[
                  const SizedBox(height: 40,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(child: Util.label("Did not receive link? check spam folder or try resending.",color: ThemeProvider.fontPrimary,fontSize: FontSize.textLg,fontWeight: FontWeight.w600,maxLines: 3,overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 15,),
                  GestureDetector(
                      onTap: ()async{
                        if(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(emailController.text)){
                          setState(() {
                            errorCode = '';
                          });
                          final response = await AuthService.sendPasswordResetEmail(emailController.text);
                          if(response != 'success'){
                            //sending reset link failed
                            setState(() {
                              errorCode = response;
                            });
                          }else{
                            Util.toast("Check inbox for reset link");
                          }
                        }else{
                          Util.toast("Invalid email.");
                        }
                      },
                      child: Util.label("resend link",color:  ThemeProvider.fontSecondary,fontSize: FontSize.textXl,fontWeight: FontWeight.w600)
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 25,
            right: 25,
            child: Column(
              children: [
                if(!emailSent)
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
                            onPressed: () async {
                              if(RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(emailController.text)){
                                setState(() {
                                  errorCode = '';
                                  isProcessing = true;
                                });
                                final response = await AuthService.sendPasswordResetEmail(emailController.text);
                                setState(() {
                                  isProcessing = false;
                                });
                                if(response == 'success'){
                                  setState(() {
                                    emailSent = true;
                                  });
                                }else{
                                  //sending reset link failed
                                  setState(() {
                                    errorCode = response;
                                  });
                                }
                              }else{
                                Util.toast("Invalid email.");
                              }
                            },
                            child: !isProcessing
                                ? Text(!isLoggedIn ? "Continue" : "Send link",
                                style: Styles.textStyle(
                                    color: ThemeProvider.accent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: FontSize.textBase + 1))
                                : SpinKitCircle(
                              color: ThemeProvider.accent,
                              size: 20,
                            )),
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