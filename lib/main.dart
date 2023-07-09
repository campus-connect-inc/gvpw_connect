import 'package:gvpw_connect/pages/developers_page.dart';
import 'package:gvpw_connect/pages/password_reset_page.dart';
import 'package:gvpw_connect/pages/settings_page.dart';
import 'package:gvpw_connect/pages/survey_submit_success_page.dart';
import 'package:gvpw_connect/pages/user_filled_surveys_page.dart';
import 'package:gvpw_connect/pages/user_profile_edit_page.dart';
import 'package:gvpw_connect/providers/notification_provider.dart';
import 'package:gvpw_connect/providers/route_provider.dart';
import 'package:gvpw_connect/providers/user_data_provider.dart';
import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:gvpw_connect/pages/login_page.dart';
import 'package:gvpw_connect/pages/surveys_page.dart';
import 'package:gvpw_connect/pages/splash_page.dart';

///Used to notify new notifications.
NotificationProvider notificationProvider = NotificationProvider();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //set analytics
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  //initialize shared preferences
  await SharedPreferencesService.init();
  //initialize notification provider object
  await notificationProvider.initialize();
  //listen to firebase messaging.
  await notificationProvider.firebaseMessaging();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider(create: (context) => RouteNameProvider()),
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: SplashPage.id,
        navigatorObservers: [MyNavigatorObserver(RouteNameProvider())],
        routes: {
          SplashPage.id: (context) => const SplashPage(),
          LoginPage.id: (context) => const LoginPage(),
          PasswordResetPage.id: (context) => const PasswordResetPage(),
          UserFilledSurveysPage.id: (context) => const UserFilledSurveysPage(),
          SurveysPage.id: (context) => const SurveysPage(),
          SurveySubmitSuccessPage.id: (context) =>
              const SurveySubmitSuccessPage(),
          UserProfileEditPage.id: (context) => const UserProfileEditPage(),
          SettingsPage.id: (context) => const SettingsPage(),
          DevelopersInfo.id: (context) => DevelopersInfo(),
        },
      ),
    );
  }
}
