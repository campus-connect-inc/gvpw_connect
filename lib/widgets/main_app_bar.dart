import 'package:gvpw_connect/pages/user_profile_edit_page.dart';
import 'package:gvpw_connect/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../pages/notifications_page.dart';
import '../providers/theme_provider.dart';
import '../styles/styles.dart';

class MainAppBar extends StatefulWidget {
  const MainAppBar(
      {Key? key, required this.scaffoldkey, required this.backgroundColor, this.hideQuickAccessBar, this.pageName})
      : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldkey;
  final Color backgroundColor;
  final bool? hideQuickAccessBar;
  final String? pageName;

  @override
  State<MainAppBar> createState() => _MainAppBarState();
}

class _MainAppBarState extends State<MainAppBar> {
  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        width: device.size.width,
        color: widget.backgroundColor,
        child: Column(
          children: [
            const SizedBox(
              height: 35,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //leading icon button
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: () {
                        widget.scaffoldkey.currentState?.openDrawer();
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Ionicons.menu_outline,
                            color: ThemeProvider.accent, size: 40),
                      ),
                    ),
                  ),
                  //page name
                  if(widget.pageName != null && widget.pageName!.isNotEmpty) ...[
                    const SizedBox(width: 20,),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          widget.pageName!,
                          style: Styles.textStyle(
                              fontSize: FontSize.textXl + 2,
                              color: ThemeProvider.accent,
                              fontWeight: FontWeight.w600
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  ] else
                    const Spacer(),
                  //quick access bar
                  if(widget.hideQuickAccessBar == null ||
                      (widget.hideQuickAccessBar != null && !widget.hideQuickAccessBar!))
                    Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50.0),
                          color: ThemeProvider.secondary),
                      child: Row(
                        children: [
                          Consumer<NotificationProvider>(
                            builder: (context, notificationProvider, child) {
                              return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const NotificationsPage()));
                                  },
                                  child: Stack(
                                    children: [
                                      Icon(Ionicons.notifications_outline,
                                          color: ThemeProvider.accent, size: 28),
                                      if(!notificationProvider.isSeen)
                                        Positioned(
                                          left: 19.0,
                                          child: Icon(Icons.brightness_1,color: ThemeProvider.accent,size: 9.0,),
                                        ),
                                    ],
                                  )
                              );
                            },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, UserProfileEditPage.id);
                              },
                              child: Icon(Ionicons.person_circle_outline,
                                  color: ThemeProvider.accent, size: 28))
                        ],
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}