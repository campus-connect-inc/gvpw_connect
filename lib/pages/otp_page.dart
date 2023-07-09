// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_data_provider.dart';
import '../styles/styles.dart';
import '../utils/auth_service.dart';
import '../utils/consts.dart';
import '../utils/shared_preferences_service.dart';
import '../utils/util.dart';
import 'surveys_page.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({
    Key? key,
    required this.userCred,
    required this.password,
  }) : super(key: key);
  static const id = "OtpScreen";
  final UserCredential userCred;
  final String password;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String? verificationCode;
  int? forceResendingToken;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///[_timeoutTimer] can be given any value from 30-120(2 min's being maximum)
  final int _timeoutTime = 30;

  TextEditingController pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool isAlreadyLinked = false;
  bool isProcessing = false;
  bool isCodeSent = false;
  bool isVerifying = false;
  String phoneNo = "";
  bool isError = false;

  ///The counter counts down from [_timeoutTime]
  int _counter = 0;
  bool _resendOTP = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }

  Future<void> _startLoginSequence(PhoneAuthCredential credential) async{
    try {
      setState(() {
        isVerifying = true;
      });
      if (isAlreadyLinked) {
        //user phone no is already linked so directly sign user in.
        //sign in the user
        await _auth
            .signInWithCredential(credential)
            .then((value) async {
          await Provider.of<UserDataProvider>(context,
              listen: false)
              .initialize();
          Provider.of<RouteNameProvider>(context, listen: false)
              .setCurrentRouteName(SurveysPage.id);
          Navigator.of(context).pushNamedAndRemoveUntil(
            SurveysPage.id,
                (route) => false,
          );
        });
      } else {
        //Link phone number to the user account and sign in.
        await _auth
            .signInWithEmailAndPassword(
            email: widget.userCred.user!.email!,
            password: widget.password)
            .then((value) async => widget.userCred.user
            ?.linkWithCredential(credential)
            .then((userCredential) async {
          await Provider.of<UserDataProvider>(context,
              listen: false)
              .initialize();
          if (kDebugMode) {
            print("Phone number linked successfully");
            print(
                "users phone-number : ${_auth.currentUser?.phoneNumber}");
          }
          Provider.of<RouteNameProvider>(context, listen: false)
              .setCurrentRouteName(SurveysPage.id);
          AuthService.isLoggedIn()
              ? Navigator.of(context)
              .pushNamedAndRemoveUntil(
            SurveysPage.id,
                (route) => false,
          )
              : null;
        }).catchError((error) {
          if (kDebugMode) {
            print(
                "Error linking phone number to user: $error");
          }
        }));
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        Util.toast(e.code);
        setState(() {
          isError = true;
        });
      }
    }
    setState(() {
      isVerifying = false;
    });
  }

  Future<void> _verificationComplete(PhoneAuthCredential credential) async {
    if(credential.smsCode != null){
      // If auto-verification is successful, this callback will be invoked.
      pinController.setText(credential.smsCode!);
      await _startLoginSequence(credential);
    }
  }

  void _verificationFailed(FirebaseAuthException e) {
    Util.toast("Verification failed(${e.code})\nQuitting.");
    Future.delayed(const Duration(seconds: 3),(){
      Navigator.of(context).pop();
    });
  }

  void _codeSent(String? verificationId, int? resendToken) {
    // set verificationId and resendToken to be used in code verification
    setState(() {
      isCodeSent = true;
    });
    verificationCode = verificationId;
    forceResendingToken = resendToken;
    // start OTP timer
    startTimer();
  }

  void _codeAutoRetrievalTimeout(String verificationID) {
    //handle timeout
  }

  void _verifyPhone() async {
    if (mounted) {
      setState(() {
        isProcessing = true;
      });
      if (widget.userCred.user?.phoneNumber == null) {
        //user account is not yet linked with the available phone number so we fetch it from db and store it in [phoneNo].
        final HttpsCallable getUserPhoneNumber =
        FirebaseFunctions.instanceFor(region: FIREBASE_CF_REGION).httpsCallable('getUserPhoneNumber');
        try {
          final response = await getUserPhoneNumber.call(<String, dynamic>{
            'orgCode': SharedPreferencesService.userOrg,
            'uid': widget.userCred.user?.uid
          });
          if (kDebugMode) {
            print(response.data);
          }
          phoneNo = '+91 ${response.data}';
        } on FirebaseFunctionsException catch (e) {
          Util.toast(e.code);
        }
      } else {
        //user account is already linked with phone number
        phoneNo = widget.userCred.user!.phoneNumber!;
        isAlreadyLinked = true;
      }
      setState(() {
        isProcessing = false;
      });
      //disable recaptcha pop-up
      await _auth.setSettings(
        forceRecaptchaFlow: false,
      );
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNo,
          verificationCompleted: _verificationComplete,
          verificationFailed: _verificationFailed,
          codeSent: _codeSent,
          codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
          forceResendingToken: forceResendingToken,
          timeout: Duration(seconds: _timeoutTime));
    }
  }

  void startTimer() {
    if (mounted) {
      _counter = _timeoutTime;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_counter > 0) {
          setState(() {
            _counter--;
          });
        } else {
          setState(() {
            _resendOTP = true;
            _timer!.cancel();
          });
        }
      });
    }
  }

  void _resendOtp() async {
    if (mounted) {
      setState(() {
        isCodeSent = false;
      });
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNo,
          forceResendingToken: forceResendingToken,
          verificationCompleted: _verificationComplete,
          verificationFailed: _verificationFailed,
          codeSent: (String? verificationId, int? resendToken) {
            setState(() {
              _resendOTP = false;
              isCodeSent = true;
            });
            _codeSent(verificationId, resendToken);
          },
          codeAutoRetrievalTimeout: _codeAutoRetrievalTimeout,
          timeout: Duration(seconds: _timeoutTime));

    }
  }

  @override
  void dispose() {
    pinController.dispose();
    _focusNode.dispose();
    if(_timer != null){
      _timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    final defaultPinTheme = PinTheme(
        height: 50,
        width: 40,
        textStyle: Styles.textStyle(
            color: ThemeProvider.fontPrimary,
            fontWeight: FontWeight.w700,
            fontSize: FontSize.text2Xl),
        decoration: const BoxDecoration(
            color: Colors.transparent,
            border:
            Border(bottom: BorderSide(color: ThemeProvider.fontPrimary, width: 2.0))));
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: Util.commonAppBar(
          context,
          name: "OTP",
          centerTitle: true,
        ),
        backgroundColor: ThemeProvider.primary,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                //Main content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "assets/illustrations/phone-security-password.svg",
                        height: device.size.height * 0.20,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Verification code",
                        style: Styles.textStyle(
                            color: ThemeProvider.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: FontSize.text2Xl),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "We have sent the code verification to Your Mobile Number",
                        style: Styles.textStyle(
                            color: ThemeProvider.fontPrimary.withOpacity(0.7),
                            fontWeight: FontWeight.w700,
                            fontSize: FontSize.textBase),
                        textAlign: TextAlign.center,
                      ),
                      if (!isProcessing) ...[
                        const SizedBox(
                          height: 30,
                        ),
                        Text(
                          phoneNo,
                          style: Styles.textStyle(
                              color: ThemeProvider.accent,
                              fontWeight: FontWeight.w700,
                              fontSize: FontSize.textXl),
                        ),
                      ],
                      const SizedBox(
                        height: 20,
                      ),
                      Pinput(
                        animationCurve: Curves.bounceIn,
                        controller: pinController,
                        showCursor: true,
                        length: 6,
                        androidSmsAutofillMethod:
                        AndroidSmsAutofillMethod.none,
                        listenForMultipleSmsOnAndroid: true,
                        focusNode: _focusNode,
                        cursor: null,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        defaultPinTheme: isError
                            ? defaultPinTheme.copyWith(
                            textStyle: Styles.textStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: FontSize.text2Xl,
                                color: Colors.red.withOpacity(0.7)),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              border: Border(
                                  bottom: BorderSide(color: Colors.red)),
                            ))
                            : defaultPinTheme,
                        onTap: () {
                          setState(() {
                            isError = false;
                          });
                        },
                        focusedPinTheme: defaultPinTheme.copyWith(
                            textStyle: Styles.textStyle(
                                color: ThemeProvider.secondary,
                                fontWeight: FontWeight.w700,
                                fontSize: FontSize.text2Xl),
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: ThemeProvider.tertiary,
                                      width: 3.0)),
                            )),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      if (!_resendOTP)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            _counter != 0 ? _counter.toString() : "",
                            style: Styles.textStyle(
                                color: ThemeProvider.fontPrimary,
                                fontSize: FontSize.textXl,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (_resendOTP)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Did not receive the code? ",
                              style: Styles.textStyle(
                                  color: ThemeProvider.fontPrimary,
                                  fontSize: FontSize.textBase,
                                  fontWeight: FontWeight.w600),
                            ),
                            GestureDetector(
                              onTap: _resendOtp,
                              child: Text(
                                "resend otp",
                                style: Styles.textStyle(
                                    color: ThemeProvider.fontSecondary,
                                    fontSize: FontSize.textBase,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 30,
              left: 25,
              right: 25,
              child: isCodeSent ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 10),
                    backgroundColor: ThemeProvider.secondary,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: !isVerifying ? () async {
                    //Verify the OTP
                    PhoneAuthCredential credential =
                    PhoneAuthProvider.credential(
                        verificationId: verificationCode!,
                        smsCode: pinController.text);
                    await _startLoginSequence(credential);
                  } : null,
                  child: !isVerifying
                      ? Text("Verify",
                      style: Styles.textStyle(
                          color: ThemeProvider.accent,
                          fontWeight: FontWeight.bold,
                          fontSize: FontSize.textLg))
                      : SpinKitCircle(
                    color: ThemeProvider.accent,
                    size: 25,
                  )) : Center(child: SpinKitThreeBounce(color: ThemeProvider.accent,size: 35,)),
            )
          ],
        ),
      ),
    );
  }
}