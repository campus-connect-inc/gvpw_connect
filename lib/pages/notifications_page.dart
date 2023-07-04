import 'package:gvpw_connect/providers/notification_provider.dart';
import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:gvpw_connect/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../styles/styles.dart';
import '../utils/util.dart';
import 'package:gvpw_connect/main.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);
  static const id = "survey_notifications_page";

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    doRoutine();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // reset isOnNotificationsPage flag
      notificationProvider.resetIsOnNotificationsPage();
    });
    super.dispose();
  }

  void doRoutine() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        setState(() {
          isLoading = true;
        });

        // set isOnNotificationsPage flag
        notificationProvider.setIsOnNotificationsPage();
        await SharedPreferencesService.waitForInitialization();
        await SharedPreferencesService.sharedPreferences!
            .setBool('isSeen', true);
        notificationProvider.setMessagesSeen();

        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Scaffold(
          appBar: Util.commonAppBar(context, name: "Notifications"),
          backgroundColor: ThemeProvider.primary,
          body: !isLoading
              ? notificationProvider.localNotifications.isNotEmpty
              ? NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowIndicator();
              return true;
            },
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount:
              notificationProvider.localNotifications.length,
              itemBuilder: (BuildContext context, int index) {
                return NotificationTile(
                    messageData: notificationProvider
                        .localNotifications[index],
                    messageIndex: index);
              },
            ),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: SvgPicture.asset(
                  "assets/illustrations/empty-inbox.svg",
                  height: device.size.height * 0.30,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Util.label("No new notifications...",
                  color: ThemeProvider.accent,
                  fontSize: FontSize.textLg,
                  fontWeight: FontWeight.w600)
            ],
          )
              : Center(
            child: SpinKitCircle(
              color: ThemeProvider.accent,
              size: 40,
            ),
          ),
        );
      },
    );
  }
}