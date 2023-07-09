import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:gvpw_connect/providers/user_data_provider.dart';
import 'package:gvpw_connect/utils/auth_service.dart';
import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:gvpw_connect/widgets/main_app_bar.dart';
import 'package:gvpw_connect/widgets/app_drawer.dart';
import 'package:gvpw_connect/widgets/fill_survey_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../styles/styles.dart';

class SurveysPage extends StatefulWidget {
  const SurveysPage({Key? key}) : super(key: key);
  static const id = "surveys_page";

  @override
  State<SurveysPage> createState() => _SurveysPageState();
}

class _SurveysPageState extends State<SurveysPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _fireStore = FirebaseFirestore.instance;
  bool noSurveys = false;

  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: ThemeProvider.primary,
        drawer: const AppDrawer(),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overScroll) {
            overScroll.disallowIndicator();
            return true;
          },
          child: Stack(
            children: [
              //body
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 95,
                    ),
                    //render survey tiles and pass data from db.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 0),
                      child: Consumer<UserDataProvider>(
                        builder: (context, userDataProvider, child) =>
                            StreamBuilder<
                                List<
                                    QueryDocumentSnapshot<
                                        Map<String, dynamic>>>>(
                              stream: Rx.combineLatest2(
                                _fireStore
                                    .collection("organizations/${SharedPreferencesService.userOrg}/surveys")
                                    .where("targetDept", whereIn: [
                                  userDataProvider.userData['dept'],
                                  'All'
                                ])
                                    .where("endDate",
                                    isGreaterThan: Timestamp.now())
                                    .orderBy('endDate', descending: false)
                                    .snapshots(),
                                _fireStore
                                    .collection("organizations/${SharedPreferencesService.userOrg}/users")
                                    .doc(AuthService.getUserUid())
                                    .collection("filledSurveys")
                                    .snapshots()
                                    .map((snapshot) => snapshot.docs
                                    .map((doc) => doc.id)
                                    .toList()),
                                    (QuerySnapshot<Map<String, dynamic>> surveys,
                                    List<String> filledSurveys) {
                                  return surveys.docs
                                      .where((survey) =>
                                  !filledSurveys.contains(survey.id))
                                      .toList();
                                },
                              ),
                              builder: (BuildContext context,
                                  AsyncSnapshot<
                                      List<
                                          QueryDocumentSnapshot<
                                              Map<String, dynamic>>>>
                                  snapshot) {
                                if (snapshot.hasData) {
                                  final List<
                                      DocumentSnapshot<Map<String, dynamic>>>
                                  documents = snapshot.data ?? [];
                                  if (documents.isNotEmpty) {
                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 20),
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      itemCount: documents.length,
                                      itemBuilder: (context, index) {
                                        final DocumentSnapshot<
                                            Map<String, dynamic>> document =
                                        documents[index];
                                        return Padding(
                                          padding:
                                          const EdgeInsets.only(bottom: 25),
                                          child: FillSurveyTile(
                                            data: document.data()!,
                                            id: document.id,
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    return Center(
                                      heightFactor: 1.6,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Lottie.asset(
                                              "assets/animations/Not found.json",
                                              frameRate: FrameRate(60.0),
                                              height: device.size.height * 0.40,
                                              repeat: true),
                                          const SizedBox(height: 15),
                                          Text(
                                            "No active surveys found",
                                            style: Styles.textStyle(
                                                color: ThemeProvider.accent,
                                                fontSize: FontSize.textXl,
                                                fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            "Sit back and relax until we get new surveys for you",
                                            style: Styles.textStyle(
                                                color:
                                                ThemeProvider.fontPrimary.withOpacity(0.7),
                                                fontSize: FontSize.textBase,
                                                fontWeight: FontWeight.w600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else if (snapshot.hasError) {
                                  return Center(
                                    heightFactor: 1.7,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Lottie.asset(
                                            "assets/animations/something-went-wrong.json",
                                            frameRate: FrameRate(60.0),
                                            height: device.size.height * 0.35,
                                            repeat: true),
                                        const SizedBox(height: 15),
                                        Text(
                                          "Something went wrong..",
                                          style: Styles.textStyle(
                                              color: ThemeProvider.fontPrimary,
                                              fontSize: FontSize.textLg,
                                              fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Center(
                                      heightFactor: 15,
                                      child: SpinKitCircle(
                                        color: ThemeProvider.accent,
                                        size: 40,
                                      ));
                                }
                              },
                            ),
                      ),
                    )
                  ],
                ),
              ),
              //main app bar
              MainAppBar(
                scaffoldkey: _scaffoldKey,
                backgroundColor: ThemeProvider.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}