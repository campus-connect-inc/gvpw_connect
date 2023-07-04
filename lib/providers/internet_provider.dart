import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../styles/styles.dart';

class InternetProvider extends StatefulWidget {
  ///Checks if there is internet connected to the device and if yes returns the given child and if no it returns a no internet widget.
  const InternetProvider({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  State<InternetProvider> createState() => _InternetProviderState();
}

class _InternetProviderState extends State<InternetProvider> {
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _subscription;
  bool _hasInternet = true;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _subscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    final hasInternet = result != ConnectivityResult.none;
    setState(() {
      _hasInternet = hasInternet;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _hasInternet
        ? widget.child
        : WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: null,
        backgroundColor: ThemeProvider.primary,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset("assets/animations/no-internet-connected.json",
                  repeat: true, frameRate: FrameRate(60.0)),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Oops, No internet Connection",
                style: Styles.textStyle(
                    color: ThemeProvider.accent,
                    fontSize: FontSize.textXl,
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Make sure wifi or cellular data is turned\n on and then try again.",
                style: Styles.textStyle(
                    color: ThemeProvider.fontPrimary.withOpacity(0.8),
                    fontSize: FontSize.textBase,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: () {
                    _connectivity
                        .checkConnectivity()
                        .then(_updateConnectionStatus);
                  },
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 10)),
                      backgroundColor: MaterialStateProperty.all<Color>(
                          ThemeProvider.secondary),
                      shape: MaterialStateProperty.all<
                          RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(
                                  color: Colors.transparent)))),
                  child: Text(
                    "TRY AGAIN",
                    style: Styles.textStyle(
                        color: ThemeProvider.accent,
                        fontWeight: FontWeight.w500,
                        fontSize: FontSize.textBase),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}