import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/internet_provider.dart';
import '../providers/theme_provider.dart';
import '../styles/styles.dart';

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _animation = Tween<double>(begin: -5, end: 5).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
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
                    color: ThemeProvider.fontPrimary,
                    fontSize: FontSize.textBase,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "The application relies entirely on an internet connection to fetch data, as nothing is stored locally. "
                    "We apologize for any inconvenience this may cause. Once you regain internet access,"
                    " you will be returned to your previous screen.",
                style: Styles.textStyle(
                    color: ThemeProvider.fontPrimary.withOpacity(0.7),
                    fontSize: FontSize.textSm,
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
                maxLines: 5,
              ),
              const SizedBox(
                height: 50,
              ),
              AnimatedBuilder(
                animation: _animation,
                builder: (BuildContext context, Widget? child) {
                  return Transform.translate(
                    offset: Offset(_animation.value, 0),
                    child: ElevatedButton(
                        onPressed: () async{
                          // this forces the consumer to rebuild and check connectivity
                          bool isConnected = await context.read<InternetProvider>().checkConnectivity();
                          if (!isConnected) {
                            _controller.forward(from: 0.0);  // Start the shaking animation
                            Future.delayed(const Duration(seconds: 1), () {
                              _controller.stop();  // Stop the shaking animation after 1 second
                            });
                          } else {
                            _controller.stop();  // Stop the shaking animation
                          }
                        },
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 10)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                ThemeProvider.secondary),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: const BorderSide(
                                        color: Colors.transparent)))),
                        child: Text(
                          "Try again",
                          style: Styles.textStyle(
                              color: ThemeProvider.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: FontSize.textBase),
                        )),
                  );
                },

              )
            ],
          ),
        ),
      ),
    );
  }
}