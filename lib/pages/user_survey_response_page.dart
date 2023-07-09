import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../styles/styles.dart';
import '../utils/auth_service.dart';
import '../utils/shared_preferences_service.dart';
import '../utils/util.dart';
import '../utils/consts.dart';

class UserSurveyResponsePage extends StatefulWidget {
  const UserSurveyResponsePage({Key? key, required this.surveyId})
      : super(key: key);
  final String surveyId;

  @override
  State<UserSurveyResponsePage> createState() => _UserSurveyResponsePageState();
}

class _UserSurveyResponsePageState extends State<UserSurveyResponsePage> {
  bool isLoading = true;
  final _fireStore = FirebaseFirestore.instance;
  Map<String, dynamic>? responseData, surveyData;
  List<Map<String,dynamic>> surveyResponse = [];
  Widget sectionName(String name) => Column(
    children: [
      Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ThemeProvider.secondary),
        child: Text(
          name,
          style: Styles.textStyle(
              color: ThemeProvider.accent,
              fontSize: FontSize.textXl,
              fontWeight: FontWeight.w700),
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ],
  );

  void fetchResponse() async {
    setState(() {
      isLoading = true;
    });

    // Fetch response data
    await _fireStore
        .collection("organizations/${SharedPreferencesService.userOrg}/users")
        .doc(AuthService.getUserUid())
        .collection("filledSurveys")
        .doc(widget.surveyId)
        .get()
        .then((document) => responseData = document.data());

    // Fetch survey data
    await _fireStore
        .collection("organizations/${SharedPreferencesService.userOrg}/surveys")
        .doc(widget.surveyId)
        .get()
        .then((document) => surveyData = document.data());

    // Fill up surveyResponse from responseData and surveyData
    // Get all sections from the "sections" collection of the survey
    QuerySnapshot<Map<String, dynamic>> sectionSnapshots = await _fireStore
        .collection("organizations/${SharedPreferencesService.userOrg}/surveys")
        .doc(widget.surveyId)
        .collection("sections")
        .orderBy("timestamp",descending: false)
        .get();
    List<QueryDocumentSnapshot<Map<String, dynamic>>> sections = sectionSnapshots.docs;
    // Iterate through each section
    for (var section in sections) {
      //Create a questions List for the section
      List<Map<String,dynamic>> sectionQuestions = [];
      Map<String,dynamic> sectionData = section.data();
      // Fetch all questions for the current section
      QuerySnapshot<Map<String, dynamic>> questionSnapshots = await section.reference
          .collection("questions")
          .get();
      List<QueryDocumentSnapshot<Map<String, dynamic>>> questions = questionSnapshots.docs;

      // Iterate through each question in the section
      for (var question in questions) {
        String questionId = question.id;

        // Check if the question exists in the response data
        if (responseData!.containsKey(questionId)) {
          // Check the question type
          String questionType = question.data()["type"];
          if (questionType == QUESTION_TYPE.mcq.toString()) {
            // Fetch the selected option index from the response data
            int selectedOptionIndex = int.parse(responseData![questionId]) - 1;
            // Fetch the options array for the question
            List<dynamic> options = question.data()["options"];
            // Check if the selected option index is valid
            if (selectedOptionIndex >= 0 && selectedOptionIndex < options.length) {
              String selectedOption = options[selectedOptionIndex];
              // Add the question and selected option to the survey response
              sectionQuestions.add({
                "questionId": questionId,
                "type" : QUESTION_TYPE.mcq.toString(),
                "question": question.data()["question"],
                "response": selectedOption,
              });
            }
          } else if (questionType == QUESTION_TYPE.textfield.toString()) {
            // Fetch the response value for the textfield question
            String responseValue = responseData![questionId];
            // Add the question and response value to the survey response
            sectionQuestions.add({
              "questionId": questionId,
              "type" : QUESTION_TYPE.textfield.toString(),
              "question": question.data()["question"],
              "response": responseValue,
            });
          }
        }
      }
      //append the questions data collected into the section map
      sectionData["questions"] = sectionQuestions;
      //add the section data into the surveyResponse
      surveyResponse.add(sectionData);
    }
    setState(() {
      isLoading = false;
    });
  }


  @override
  void initState() {
    super.initState();
    fetchResponse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Util.commonAppBar(context, name: "Response"),
      backgroundColor: ThemeProvider.primary,
      body: !isLoading
          ? NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overScroll) {
          overScroll.disallowIndicator();
          return true;
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Util.label(surveyData!["name"],
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 25),
                    const SizedBox(
                      height: 10,
                    ),
                    Util.label(surveyData!["about"],
                        color: Colors.white70),
                    const SizedBox(
                      height: 20,
                    ),
                    Util.label("Submitted on  ",
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                    const SizedBox(
                      height: 5,
                    ),
                    Util.label(
                        Util.formatTimestamp(
                            responseData!["submittedOn"]),
                        color: ThemeProvider.fontSecondary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                    const SizedBox(height: 15,),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: surveyResponse.length,
                      itemBuilder: (BuildContext context, int sectionIndex) {
                        Map<String,dynamic> sectionData = surveyResponse[sectionIndex];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10,),
                            if(sectionData.containsKey("sectionName"))
                              Util.sectionName(sectionData["sectionName"]),
                            if(sectionData.containsKey("sectionPrelude"))
                              Util.label(sectionData["sectionPrelude"],fontSize: FontSize.textBase,color: Colors.white.withOpacity(0.8)),
                              const SizedBox(height: 15,),
                            ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: surveyResponse[sectionIndex]["questions"].length,
                              itemBuilder: (BuildContext context, int questionIndex) {
                                Map<String,dynamic> questionData = surveyResponse[sectionIndex]["questions"][questionIndex];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Util.label(questionData["question"],color: Colors.white,fontSize: FontSize.textXl),
                                      const SizedBox(height: 10,),
                                      Util.label(questionData["response"],color: Colors.blue,fontSize: FontSize.textLg)
                                    ],
                                  ),
                                );
                              },
                            )
                          ],
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SpinKitCircle(
              color: ThemeProvider.accent,
              size: 60,
            ),
          )
        ],
      ),
    );
  }
}