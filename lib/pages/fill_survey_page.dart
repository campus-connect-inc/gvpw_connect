// ignore_for_file: must_be_immutable, use_build_context_synchronously
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gvpw_connect/pages/survey_submit_success_page.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:gvpw_connect/utils/database_service.dart';
import 'package:flutter/material.dart';
import '../styles/styles.dart';
import '../utils/shared_preferences_service.dart';
import '../utils/util.dart';
import '../utils/consts.dart';
import '../widgets/survey_mcq_tile.dart';
import '../widgets/survey_textfield_tile.dart';



class FillSurveyPage extends StatefulWidget {
  const FillSurveyPage({Key? key, required this.surveyId}) : super(key: key);
  static const id = "fill_survey_page";
  final String surveyId;
  static Map<String, dynamic> surveyResponse = {};

  static get responseMap => surveyResponse;

  static void updateResponse(String questionId, String optionId) =>
      surveyResponse[questionId] = optionId;

  @override
  State<FillSurveyPage> createState() => _FillSurveyPageState();
}

class _FillSurveyPageState extends State<FillSurveyPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _fireStore = FirebaseFirestore.instance;
  bool isLoading = true;
  Map<String, dynamic> surveyData = {};
  List<DocumentSnapshot> sections = [];
  List<String> allQuestionIds = [];
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchSurvey();
  }

  fetchSurvey() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
      try {
        // Fetch survey data
        DocumentSnapshot<Map<String, dynamic>> surveyDoc = await _fireStore
            .collection(
                "organizations/${SharedPreferencesService.userOrg}/surveys")
            .doc(widget.surveyId)
            .get();
        surveyData = surveyDoc.data() as Map<String, dynamic>;
        surveyData["sections"] = [];
        // Fetch survey sections
        QuerySnapshot<Map<String, dynamic>> sectionSnapshots = await _fireStore
            .collection(
                "organizations/${SharedPreferencesService.userOrg}/surveys")
            .doc(widget.surveyId)
            .collection("sections")
            .orderBy("timestamp",descending: false)
            .get();
        sections = sectionSnapshots.docs;

        // Fetch questions for each section
        for (var section in sections) {
          // Fetch section data
          Map<String, dynamic> sectionData =
              section.data() as Map<String, dynamic>;

          // Fetch questions for the current section
          QuerySnapshot<
              Map<String,
                  dynamic>> questionSnapshots = await _fireStore
              .collection(
                  "organizations/${SharedPreferencesService.userOrg}/surveys")
              .doc(widget.surveyId)
              .collection("sections")
              .doc(section.id)
              .collection("questions")
              .get();

          // Store question data in the section's map
          List<Map<String, dynamic>> questions =
              questionSnapshots.docs.map((question) {
            return question.data();
          }).toList();
          sectionData['questions'] = questions;
          for (var question in questions) {
            allQuestionIds.add(question["id"]);
          }
          surveyData["sections"].add(sectionData);
        }
        setState(() {
          isLoading = false;
        });
      } catch (error) {
        // Handle error
        Exception("Error fetching survey: $error");
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget sectionName(String name) => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ThemeProvider.secondary),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: Styles.textStyle(
                        color: ThemeProvider.accent,
                        fontSize: FontSize.textLg,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      );

  Widget sectionAbout(String about) => Column(
        children: [
          Text(
            about,
            style: Styles.textStyle(
                color: ThemeProvider.fontPrimary.withOpacity(0.8),
                fontSize: FontSize.textBase,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 25,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    FillSurveyPage.surveyResponse["surveyId"] = widget.surveyId;
    return Scaffold(
      appBar: Util.commonAppBar(context, name: "Fill survey"),
      key: _scaffoldKey,
      backgroundColor: ThemeProvider.primary,
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overScroll) {
          overScroll.disallowIndicator();
          return true;
        },
        child: !isLoading
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    //Body
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surveyData['name'].trim().toUpperCase(),
                            style: Styles.textStyle(
                                color: ThemeProvider.accent,
                                fontSize: FontSize.text2Xl,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            surveyData['about'].trim(),
                            style: Styles.textStyle(
                                color: ThemeProvider.tertiary,
                                fontSize: FontSize.textBase,
                                fontWeight: FontWeight.w600),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: surveyData["sections"].length,
                            itemBuilder: (context, sectionIndex) {
                              final Map sectionData =
                                  surveyData["sections"][sectionIndex];
                              List<Map<String, dynamic>> questions =
                                  sectionData["questions"];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (sectionData["sectionName"]
                                      .trim()
                                      .isNotEmpty) ...[
                                    Util.sectionName(
                                        sectionData["sectionName"].trim()),
                                    if (sectionData["sectionPrelude"]
                                        .trim()
                                        .isNotEmpty) ...[
                                      sectionAbout(
                                          sectionData["sectionPrelude"]
                                              .trim()),
                                    ]
                                  ],
                                  ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: surveyData["sections"]
                                            [sectionIndex]["questions"]
                                        .length,
                                    itemBuilder: (context, questionIndex) {
                                      Map<String, dynamic> question =
                                          questions[questionIndex];
                                      String questionType = question["type"];
                                      if(questionType == QUESTION_TYPE.mcq.toString()){
                                        List<Option> options = [];
                                        List fetchedOptions =
                                        question["options"];
                                        for (int i = 0;
                                        i < fetchedOptions.length;
                                        i++) {
                                          options.add(Option(
                                              id: (i + 1).toString().trim(),
                                              text: fetchedOptions[i]));
                                        }
                                        return Padding(
                                          padding:
                                          const EdgeInsets.only(bottom: 20),
                                          child: SurveyMcqTile(
                                              question: Question(
                                                questionId: question['id'],
                                                question:
                                                question["question"].trim(),
                                                options: options,
                                              )),
                                        );
                                      }else if(questionType == QUESTION_TYPE.textfield.toString()){
                                        return Padding(
                                          padding:
                                          const EdgeInsets.only(bottom: 20),
                                          child: SurveyTextfieldTile(
                                            question: question,
                                          ),
                                        );
                                      }else{
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  )
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: !isSubmitting ?  () async {
                                  setState(() {
                                    isSubmitting = true;
                                  });
                                  //check if user filled all the questions
                                  //by verifying that all questionIds are existing in responseMap
                                  bool didFillAll = false;
                                  for (var questionId in allQuestionIds) {
                                    if (FillSurveyPage.surveyResponse
                                        .containsKey(questionId)) {
                                      didFillAll = true;
                                    } else {
                                      didFillAll = false;
                                      break;
                                    }
                                  }
                                  //if yes send response
                                  if (didFillAll) {
                                    //get present date and store it in response.
                                    FillSurveyPage
                                            .surveyResponse["submittedOn"] =
                                        Timestamp.now();
                                    await DatabaseService.submitFilledSurvey(
                                        FillSurveyPage.surveyResponse);
                                    Navigator.pushReplacementNamed(
                                        context, SurveySubmitSuccessPage.id);
                                  } else {
                                    Util.toast(
                                        "Please fill in all the survey questions");
                                  }
                                  setState(() {
                                    isSubmitting = false;
                                  });
                                } : null,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  backgroundColor: ThemeProvider.accent,
                                  shadowColor: Colors.black45,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 3),
                                  child: !isSubmitting ? Text(
                                    "Submit",
                                    style: Styles.textStyle(
                                        color: ThemeProvider.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: FontSize.textBase),
                                  ) : SpinKitCircle(color: ThemeProvider.accent,size: 30,),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              )
            : Center(
                child: SpinKitCircle(
                  color: ThemeProvider.accent,
                  size: 40,
                ),
              ),
      ),
    );
  }
}
