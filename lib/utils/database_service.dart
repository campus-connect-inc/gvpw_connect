import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:gvpw_connect/utils/util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import './consts.dart';
class DatabaseService {

  ///checks if an user document exists
  static Future<bool> checkIfUserDocExists() async {
    final auth = FirebaseAuth.instance;
    final fireStore = FirebaseFirestore.instance;
    await auth.currentUser!.reload();
    final userDoc =
    await fireStore.collection("organizations/${SharedPreferencesService.userOrg}/users").doc(auth.currentUser!.uid).get();
    return userDoc.exists;
  }

  //Non functional function
  static Future<void> submitFilledSurveyUsingCloud(
      Map<String, dynamic> surveyResponse) async {
    final HttpsCallable submitFilledSurvey =
    FirebaseFunctions.instanceFor(region: FIREBASE_CF_REGION).httpsCallable('submitFilledSurvey');
    try {
      final response = await submitFilledSurvey
          .call(<String, dynamic>{'surveyResponse': surveyResponse});
      if (kDebugMode) {
        print(response.data);
      }
    } on FirebaseFunctionsException catch (e) {
      Util.toast(e.code);
    }
  }

  static Future<void> submitFilledSurvey(
      Map<String, dynamic> surveyResponse) async {
    try {
      final auth = FirebaseAuth.instance;
      CollectionReference collectionRef =
      FirebaseFirestore.instance.collection('organizations/${SharedPreferencesService.userOrg}/users');
      CollectionReference surveys =
      FirebaseFirestore.instance.collection('organizations/${SharedPreferencesService.userOrg}/surveys');
      DocumentReference userRef = collectionRef.doc(auth.currentUser?.uid);
      DocumentReference surveyRef = surveys.doc(surveyResponse["surveyId"]);
      // Create the user document if it doesn't exist
      Map<String, dynamic> emptyMap = {};
      await userRef.set(emptyMap, SetOptions(merge: true));

      CollectionReference filledSurveys = userRef.collection('filledSurveys');
      DocumentReference survey = filledSurveys.doc(surveyResponse["surveyId"]);
      await survey.set(surveyResponse);
      await surveyRef.update({
        'submittedUsers': FieldValue.arrayUnion([auth.currentUser?.uid])
      });
      //send notification to all the users that the survey has been posted.
    } on FirebaseException catch (e) {
      Util.toast('Error submitting survey response: ${e.code}');
    }
  }
}