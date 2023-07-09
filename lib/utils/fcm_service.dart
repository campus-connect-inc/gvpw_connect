import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FcmService{
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
    final String allTopic = '${SharedPreferencesService.userOrg}_All';
    final String deptTopic = '${SharedPreferencesService.userOrg}_$dept';
    await messaging.subscribeToTopic(allTopic);
    await messaging.subscribeToTopic(deptTopic);
    if(kDebugMode){
      print('Successfully subscribe to topics  : $allTopic & $deptTopic');
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
    final userOrg = await SharedPreferencesService.getUserOrganisation();
    final usersRef = FirebaseFirestore.instance.collection('organizations/$userOrg/users');
    final userDoc = usersRef.doc(user.uid);
    await userDoc.update({'fcmToken': await getFcmToken()});
  }

}