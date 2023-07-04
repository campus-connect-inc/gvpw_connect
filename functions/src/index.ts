/* eslint-disable linebreak-style */
import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

exports.checkHealth = functions.https.onCall(async (data, context) => {
  return "The function is online";
});

// Used by the user to send the survey response to firestore.
export const submitFilledSurvey = functions.https.onCall(
  async (data, context) => {
    const auth = context.auth;
    const surveyResponse = data.surveyResponse;

    if (!auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to submit survey response"
      );
    }

    if (!surveyResponse) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Survey response data must be provided"
      );
    }

    try {
      const collectionRef = admin.firestore().collection("Users");
      const surveysRef = admin.firestore().collection("Surveys");
      const userRef = collectionRef.doc(auth.uid);
      const surveyRef = surveysRef.doc(surveyResponse.surveyId);

      // Create the user document if it doesn't exist
      await userRef.set({}, {merge: true});

      const filledSurveysRef = userRef.collection("filledSurveys");
      const surveyDoc = filledSurveysRef.doc(surveyResponse.surveyId);
      await surveyDoc.set(surveyResponse);

      await surveyRef.update({
        submittedUsers: admin.firestore.FieldValue.arrayUnion(auth.uid),
      });

      return {message: "success"};
    } catch (error) {
      console.error(`Error submitting survey response: ${error}`);
      throw new functions.https.HttpsError(
        "internal",
        "Error submitting survey response"
      );
    }
  }
);

exports.getUserPhoneNumber = functions.https.onCall(async (data, context) => {
  const orgCode = data.orgCode;
  const uid = data.uid;
  try {
    const userDocRef = admin
      .firestore()
      .doc(`organizations/${orgCode}/users/${uid}`);
    const userDoc = await userDocRef.get();

    if (userDoc.exists) {
      const phoneNo = userDoc.get("phoneNo");
      return phoneNo;
    } else {
      throw new functions.https.HttpsError(
        "not-found",
        "User document not found."
      );
    }
  } catch (error) {
    console.error("Error getting user phone number:", error);
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred while getting user phone number."
    );
  }
});
