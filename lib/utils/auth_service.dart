// ignore_for_file: use_build_context_synchronously
import 'package:cloud_functions/cloud_functions.dart';
import 'package:gvpw_connect/pages/login_page.dart';
import 'package:gvpw_connect/utils/consts.dart';
import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:gvpw_connect/utils/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  ///Test fcf health
  static Future<Map<String,dynamic>> checkStatus() async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: FIREBASE_CF_REGION).httpsCallable("checkStatus");
    final response = await callable.call({});
    if (response.data != null) {
      return response.data;
    }else{
      return{
        "status" : "offline"
      };
    }
  }

  ///is user logged in
  static bool isLoggedIn() {
    final auth = FirebaseAuth.instance;
    return auth.currentUser != null ? true : false;
  }

  static Future<String> sendPasswordResetEmail(String email)async{
    final auth = FirebaseAuth.instance;
    try{
      await auth.sendPasswordResetEmail(email: email);
      return "success";
    }on FirebaseAuthException catch(e){
      return e.code.toString();
    }
  }

  static String? getUserUid() {
    final auth = FirebaseAuth.instance;
    return auth.currentUser?.uid;
  }

  static Future<String> getUserAuthToken() {
    final auth = FirebaseAuth.instance;
    return auth.currentUser!.getIdToken();
  }

  static String? getUserPhoneNo() {
    final auth = FirebaseAuth.instance;
    return auth.currentUser?.phoneNumber;
  }

  static String? getUserEmail() {
    final auth = FirebaseAuth.instance;
    return auth.currentUser?.email;
  }

  static String? getUserPhotoUrl() {
    final auth = FirebaseAuth.instance;
    return auth.currentUser?.photoURL;
  }

  static Future<void> updateUserPhotoUrl(String? url) async {
    final auth = FirebaseAuth.instance;
    await auth.currentUser?.updatePhotoURL(url);
  }

  ///to logout
  static Future<void> logOut(BuildContext context) async {
    try {
      final auth = FirebaseAuth.instance;
      await auth.signOut();
      Navigator.pop(context, true);
      //set organisation
      await SharedPreferencesService.setUserOrganisation('gvpcew');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false, // remove all routes in the stack
      );
    } on FirebaseAuthException catch (e) {
      Util.toast(e.message!);
    }
  }

  ///check if user email is verified
  static Future<bool> isUserEmailVerified() async {
    final auth = FirebaseAuth.instance;
    await auth.currentUser!.reload();
    bool ver = auth.currentUser!.emailVerified;
    return ver;
  }

  ///send user a verification email
  static Future<void> sendUserVerificationEmail() async {
    final auth = FirebaseAuth.instance;
    await auth.currentUser!.reload();
    final user = auth.currentUser;
    await user!.sendEmailVerification();
  }
}
