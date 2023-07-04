import 'package:gvpw_connect/pages/splash_page.dart';
import 'package:flutter/material.dart';

class RouteNameProvider extends ChangeNotifier {
  String _currentRouteName = SplashPage.id;
  String get currentRouteName => _currentRouteName;

  void setCurrentRouteName(String routeName) {
    if (routeName != _currentRouteName) {
      _currentRouteName = routeName;
      notifyListeners();
    }
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  final RouteNameProvider routeNameProvider;

  MyNavigatorObserver(this.routeNameProvider);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      routeNameProvider.setCurrentRouteName(route.settings.name!);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null && previousRoute.settings.name != null) {
      routeNameProvider.setCurrentRouteName(previousRoute.settings.name!);
    }
  }

}
