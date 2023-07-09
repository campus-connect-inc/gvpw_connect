import 'package:gvpw_connect/providers/notification_provider.dart';
import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:gvpw_connect/widgets/notification_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ionicons/ionicons.dart';
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

  void showPickOptions(NotificationProvider notificationProvider) => showModalBottomSheet(
    backgroundColor: ThemeProvider.primary,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.clear_all,
                color: ThemeProvider.fontPrimary,
              ),
              title: Text(
                'clear all',
                style: Styles.textStyle(
                    color: ThemeProvider.accent,
                    fontWeight: FontWeight.w500,
                    fontSize: FontSize.textLg),
              ),
              onTap: notificationProvider.localNotifications.isNotEmpty ? () async {
                Navigator.pop(context);
                bool? response = await Util.commonAlertDialog(context,
                    title: "Clear all notifications?",
                    body: "Are you sure that you want to delete all notifications?",
                    agreeLabel: "Yes",
                    denyLabel: "cancel");
                if(response != null && response){
                  await notificationProvider.clearAllLocalNotifications();
                }
              } : null,
            ),
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Scaffold(
          appBar: Util.commonAppBar(context, name: "Notifications", actions: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: IconButton(
                splashRadius: 20.0,
                icon: const Icon(Ionicons.ellipsis_vertical),
                onPressed: (){
                  showPickOptions(notificationProvider);
                },
              ),
            ),
          ]),
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