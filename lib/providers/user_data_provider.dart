import 'package:gvpw_connect/utils/auth_service.dart';
import 'package:gvpw_connect/utils/fcm_service.dart';
import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../utils/util.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserDataProvider with ChangeNotifier {
  late User _user;
  bool isInitialized = false;
  bool isAdmin = false;
  late DocumentSnapshot<Map<String, dynamic>> _userSnapshot;
  late Map<String, dynamic> _userData;
  late String userAuthToken;
  File? profilePicture;

  User get user => _user;

  DocumentSnapshot<Map<String, dynamic>> get userSnapshot => _userSnapshot;

  Map<String, dynamic> get userData => _userData;

  //additional information
  //These variables are updated only when user is editing in editProfile screen.
  String personalEmail = "";
  String secondaryPhoneNo = "";
  String careTakerPhoneNo = "";
  File? newProfilePicture;

  void setProfilePicture(File image) => newProfilePicture = image;

  void setPersonalEmail(String email) => personalEmail = email;

  void setSecondaryPhoneNo(String phoneNo) => secondaryPhoneNo = phoneNo;

  void setCareTakerPhoneNo(String phoneNo) => careTakerPhoneNo = phoneNo;

  Future<void> initialize() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user == null) {
      throw Exception('User is not signed in');
    }
    _user = user;
    //get user organisation
    String? orgCode = await SharedPreferencesService.getUserOrganisation();
    final usersRef = FirebaseFirestore.instance.collection('organizations/$orgCode/users');
    final userDoc = usersRef.doc(user.uid);
    _userSnapshot = await userDoc.get();
    _userData = _userSnapshot.data()!;
    if (userData["rollNo"].toLowerCase().contains("admin")) {
      isAdmin = true;
    }
    //subscribe user to cloud messaging topic
    await FcmService.subscribeToTopic(_userData['dept']);
    //get auth token
    userAuthToken = await AuthService.getUserAuthToken();
    //get fcm token
    String? fcmToken = await FcmService.getFcmToken();
    //set fcm token if the field fcm token is empty.
    if ((userData["fcmToken"] == null || userData["fcmToken"].isEmpty) ||
        (userData["fcmToken"] != null && userData['fcmToken'] != fcmToken)) {
      await FcmService.setFcmToken();
    }
    // set user display picture
    String? userDisplayPicUrl = AuthService.getUserPhotoUrl();
    if (userDisplayPicUrl != null && userDisplayPicUrl.isNotEmpty) {
      profilePicture = await DefaultCacheManager().getSingleFile(
          userDisplayPicUrl,
          headers: {'Authorization': 'Bearer $userAuthToken'});
    }
    isInitialized = true;
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('organizations/${SharedPreferencesService.userOrg}/users')
          .doc(_user.uid)
          .update(data);
      _userSnapshot = await FirebaseFirestore.instance
          .collection('organizations/${SharedPreferencesService.userOrg}/users')
          .doc(_user.uid)
          .get();
      _userData = _userSnapshot.data()!;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Failed to update user data: ${e.code}');
      }
      Util.toast(e.code);
    }
  }

  Future<void> getLatestUserData() async {
    _userSnapshot = await FirebaseFirestore.instance
        .collection('organizations/${SharedPreferencesService.userOrg}/users')
        .doc(_user.uid)
        .get();
    _userData = _userSnapshot.data()!;
    notifyListeners();
  }

  Future<void> uploadProfilePicture() async {
    try {
      String userUid = AuthService.getUserUid()!;
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('organizations/${SharedPreferencesService.userOrg}/userProfilePictures/$userUid.jpg');

      // Upload the file to Cloud Storage
      await storageRef.putFile(newProfilePicture!);

      // Get the download URL and creation time for the file
      final metadata = await storageRef.getMetadata();
      final String downloadURL = await storageRef.getDownloadURL();
      final DateTime? creationTime = metadata.updated;

      // Append the creation time to the download URL
      final encodedTime =
      base64Url.encode(creationTime!.toIso8601String().codeUnits);
      final downloadURLWithTime = '$downloadURL?t=$encodedTime';
      // Update the profile picture link in Firestore
      await FirebaseFirestore.instance
          .collection('organizations/${SharedPreferencesService.userOrg}/users')
          .doc(userUid)
          .update({'profilePicture': downloadURLWithTime});

      // Update the profile picture in Firebase Authentication
      await AuthService.updateUserPhotoUrl(downloadURLWithTime);

      ///update [profilePicture] with [newProfilePicture]
      profilePicture = newProfilePicture;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Failed to update user profile picture: ${e.code}');
      }
      Util.toast(e.code);
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('Failed to update user profile picture: $e');
      }
      Util.toast(e.toString());
    }
  }
  Future<void> removeProfilePicture() async {
    try{
      String userUid = AuthService.getUserUid()!;
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('organizations/${SharedPreferencesService.userOrg}/userProfilePictures/$userUid.jpg');
      await storageRef.delete();
      await FirebaseFirestore.instance
          .collection('organizations/${SharedPreferencesService.userOrg}/users')
          .doc(userUid)
          .update({'profilePicture': null});

      // Remove the profile picture in Firebase Authentication
      await AuthService.updateUserPhotoUrl(null);

      ///update [profilePicture] with null
      profilePicture = null;
      Util.toast("Profile Picture Removed");
    }on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Failed to update user profile picture: ${e.code}');
      }
      Util.toast(e.code);
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        print('Failed to update user profile picture: $e');
      }
      Util.toast(e.toString());
    }
    notifyListeners();
  }
}

