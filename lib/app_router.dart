import 'package:flutter/material.dart';
import 'package:gvpw_connect/pages/developers_page.dart';
import 'package:gvpw_connect/pages/password_reset_page.dart';
import 'package:gvpw_connect/pages/settings_page.dart';
import 'package:gvpw_connect/pages/survey_submit_success_page.dart';
import 'package:gvpw_connect/pages/user_filled_surveys_page.dart';
import 'package:gvpw_connect/pages/user_profile_edit_page.dart';
import 'package:gvpw_connect/pages/login_page.dart';
import 'package:gvpw_connect/pages/surveys_page.dart';
import 'package:gvpw_connect/pages/splash_page.dart';


class AppRouter{
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case SplashPage.id:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case LoginPage.id:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case PasswordResetPage.id:
        return MaterialPageRoute(builder: (_) => const PasswordResetPage());
      case UserFilledSurveysPage.id:
        return MaterialPageRoute(builder: (_) => const UserFilledSurveysPage());
      case SurveysPage.id:
        return MaterialPageRoute(builder: (_) => const SurveysPage());
      case SurveySubmitSuccessPage.id:
        return MaterialPageRoute(builder: (_) => const SurveySubmitSuccessPage());
      case UserProfileEditPage.id:
        return MaterialPageRoute(builder: (_) => const UserProfileEditPage());
      case SettingsPage.id:
        return MaterialPageRoute(builder: (_) => const  SettingsPage());
      case DevelopersPage.id:
        return MaterialPageRoute(builder: (_) => const DevelopersPage());
      default:
        return MaterialPageRoute(builder: (_) => const SplashPage());
    }
  }
}