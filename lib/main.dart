import 'package:gvpw_connect/app_router.dart';
import 'package:gvpw_connect/pages/no_internet_page.dart';
import 'package:gvpw_connect/pages/splash_page.dart';
import 'package:gvpw_connect/providers/internet_provider.dart';
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
        ChangeNotifierProvider(create: (context) => InternetProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: SplashPage.id,
        navigatorObservers: [MyNavigatorObserver(RouteNameProvider())],
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              Consumer<InternetProvider>(
                builder: (context, internetProvider, child) {
                  if (!internetProvider.hasInternet) {
                    return const NoInternetPage();
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
