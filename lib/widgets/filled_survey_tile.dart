import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../pages/user_survey_response_page.dart';
import '../providers/theme_provider.dart';
import '../styles/styles.dart';
import '../utils/shared_preferences_service.dart';
import '../utils/util.dart';

class FilledSurveyTile extends StatefulWidget {
  const FilledSurveyTile(
      {super.key, required this.surveyId, required this.data});

  final String surveyId;
  final Map<String, dynamic> data;

  @override
  State<FilledSurveyTile> createState() => _FilledSurveyTileState();
}

class _FilledSurveyTileState extends State<FilledSurveyTile> {
  final _fireStore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10.0),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: (){
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      UserSurveyResponsePage(
                          surveyId: widget.surveyId)));
        },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: ThemeProvider.secondary,
                gradient: LinearGradient(
                    begin: FractionalOffset.bottomLeft,
                    end: FractionalOffset.topRight,
                    colors: [
                      ThemeProvider.tertiary.withOpacity(0.8),
                      ThemeProvider.tertiary.withOpacity(0.7),
                      ThemeProvider.secondary.withOpacity(0.7),
                      ThemeProvider.secondary.withOpacity(0.5),
                    ],
                    stops: const [
                      0.16,
                      0.30,
                      0.64,
                      0.96,
                    ])),
            child: StreamBuilder(
              stream: _fireStore
                  .collection("organizations/${SharedPreferencesService.userOrg}/surveys")
                  .doc(widget.surveyId)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                  snapshot) {
                if (snapshot.hasData && snapshot.data!.data() != null) {
                  Map<String, dynamic> survey = snapshot.data!.data()!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        survey["name"].trim(),
                        style: Styles.textStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: FontSize.text2Xl - 2,
                          color: ThemeProvider.fontPrimary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          "Submitted on : ${Util.formatTimestamp(widget.data["submittedOn"])}",
                          style: Styles.textStyle(
                              color: Colors.green, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        survey["about"].trim(),
                        style: Styles.textStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: FontSize.textBase,
                          color: ThemeProvider.fontPrimary,
                        ),
                      ),
                      const Align(
                        //change alignment for liking.[default:left]
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.arrow_right_alt_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(
                    child: SpinKitCircle(
                      color: ThemeProvider.fontPrimary,
                      size: 30,
                    ),
                  );
                }
              },
            )),
      ),
    );
  }
}