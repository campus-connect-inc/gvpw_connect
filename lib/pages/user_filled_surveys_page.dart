import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:gvpw_connect/providers/internet_provider.dart';
import 'package:gvpw_connect/providers/user_data_provider.dart';
import 'package:gvpw_connect/utils/auth_service.dart';
import 'package:gvpw_connect/widgets/filled_survey_tile.dart';
import 'package:gvpw_connect/widgets/main_app_bar.dart';
import 'package:gvpw_connect/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../styles/styles.dart';
import '../utils/shared_preferences_service.dart';

class UserFilledSurveysPage extends StatefulWidget {
  const UserFilledSurveysPage({super.key});

  static const id = "user_filled_surveys_page";

  @override
  State<UserFilledSurveysPage> createState() => _UserFilledSurveysPageState();
}

class _UserFilledSurveysPageState extends State<UserFilledSurveysPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _fireStore = FirebaseFirestore.instance;
  bool noSurveys = false;

  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    return InternetProvider(
      child: WillPopScope(
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
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 80,
                      ),
                      //render survey tiles and pass data from db.
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 0),
                        child: Consumer<UserDataProvider>(
                          builder: (context, userDataProvider, child) =>
                              StreamBuilder(
                                stream: _fireStore
                                    .collection("organizations/${SharedPreferencesService.userOrg}/users")
                                    .doc(AuthService.getUserUid()!)
                                    .collection("filledSurveys")
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot) {
                                  if (snapshot.hasData) {
                                    final List<
                                        DocumentSnapshot<Map<String, dynamic>>>
                                    documents = snapshot.data?.docs ?? [];
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
                                            child: FilledSurveyTile(
                                              surveyId: document.id,
                                              data: document.data()!,
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
                                              "You have no filled surveys..",
                                              style: Styles.textStyle(
                                                  color: ThemeProvider.accent,
                                                  fontSize: FontSize.textXl + 2,
                                                  fontWeight: FontWeight.w600),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              "Fill a survey to see your response.",
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
      ),
    );
  }
}