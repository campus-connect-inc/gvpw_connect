// ignore_for_file: use_build_context_synchronously
import 'package:cloud_functions/cloud_functions.dart';
import 'package:gvpw_connect/pages/login_page.dart';
import 'package:gvpw_connect/utils/consts.dart';
import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:gvpw_connect/utils/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthService {
  ///Test fcf health
  static Future<Map<String,dynamic>> checkStatus() async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: firebaseCFRegion).httpsCallable("checkStatus");
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

  ///for login screen
  static Future<void> logInWithEmailPass(String email, String password) async {
    try {
      final auth = FirebaseAuth.instance;
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Util.toast(e.message!);
    }
  }

  ///Create user with email and password
  static Future<void> createUser(String email, String password) async {
    try {
      final auth = FirebaseAuth.instance;
      await auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      Util.toast(e.message!);
    }
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

  ///change user password
  static Future<void> changeUserPassword() async {
    final auth = FirebaseAuth.instance;
    final fireStore = FirebaseFirestore.instance;
    final userDetails =
        await fireStore.collection("Users").doc(auth.currentUser?.uid).get();
    final userEmail = userDetails["email"];
    await auth.sendPasswordResetEmail(email: userEmail);
  }

  ///Ask for users permission to send notifications via firebase cloud messaging
  static Future<void> getFcmNotificationPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    if (kDebugMode) {
      print('Notification permission: ${settings.authorizationStatus}');
    }
  }
  ///subscribe user to cloud messaging topics
  static Future<void> subscribeToTopic(String dept)async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.subscribeToTopic('All');
    messaging.subscribeToTopic(dept.trim());
    if(kDebugMode){
      print('Successfully subscribe to topic : $dept');
    }
  }

  ///FCM token is a unique identifier for every user device,used to send push notifications
  static Future<String?> getFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    return fcmToken;
  }

  ///Gets the fcm token from the method [getFcmToken] and sets it to the user doc.
  static Future<void> setFcmToken() async {
    if (kDebugMode) {
      print("Setting user fcm token");
    }
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser!;
    final usersRef = FirebaseFirestore.instance.collection('Users');
    final userDoc = usersRef.doc(user.uid);
    await userDoc.update({'fcmToken': await getFcmToken()});
  }

  ///checks if an user document exists.
  static Future<bool> checkIfUserDocExists() async {
    final auth = FirebaseAuth.instance;
    final fireStore = FirebaseFirestore.instance;
    await auth.currentUser!.reload();
    final userDoc =
        await fireStore.collection("Users").doc(auth.currentUser!.uid).get();
    return userDoc.exists;
  }
}
