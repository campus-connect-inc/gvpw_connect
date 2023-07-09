import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  bool _hasInternet = true;

  InternetProvider() {
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  bool get hasInternet => _hasInternet;

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    bool previousInternetStatus = _hasInternet;
    if (result == ConnectivityResult.none) {
      _hasInternet = false;
    } else {
      _hasInternet = true;
    }
    if (previousInternetStatus != _hasInternet) {
      notifyListeners();
    }
  }

  Future<bool> checkConnectivity() async {
    ConnectivityResult result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _hasInternet;
  }
}
