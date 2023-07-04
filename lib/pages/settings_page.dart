// ignore_for_file: use_build_context_synchronously

import 'package:gvpw_connect/pages/developers_page.dart';
import 'package:gvpw_connect/pages/password_reset_page.dart';
import 'package:gvpw_connect/providers/internet_provider.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import '../styles/styles.dart';
import '../utils/auth_service.dart';
import '../utils/util.dart';
import '../widgets/app_drawer.dart';
import '../widgets/main_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const id = 'settings_page';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return InternetProvider(
      child: WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: ThemeProvider.primary,
          resizeToAvoidBottomInset: false,
          appBar: null,
          drawer: const AppDrawer(),
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overScroll) {
              overScroll.disallowIndicator();
              return true;
            },
            child: Stack(
              children: [
                //body
                Positioned(
                  top: 100,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          title: Util.label("Reset password",
                              color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
                          subtitle: Util.label("Get a password reset link",
                              color: ThemeProvider.fontPrimary.withOpacity(0.7), fontSize: FontSize.textSm),
                          leading: const Icon(
                            Icons.lock_reset_outlined,
                            color: ThemeProvider.iconSecondary,
                            size: 40,
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, PasswordResetPage.id);
                          },
                        ),
                        ListTile(
                          title: Util.label("Report a bug",
                              color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
                          subtitle: Util.label(
                              "Help us fix issues by reporting in app bugs.",
                              color: ThemeProvider.fontPrimary.withOpacity(0.7),
                              fontSize: FontSize.textSm),
                          leading: const Icon(
                            Icons.bug_report,
                            color: ThemeProvider.iconSecondary,
                            size: 40,
                          ),
                          onTap: () async{
                            Util.launchLink('https://github.com/campus-connect-inc/gvpw_connect/issues/new/choose');
                          },
                        ),
                        ListTile(
                          title: Util.label("Themes",
                              color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
                          subtitle: Util.label("Manage app colors & styles",
                              color: ThemeProvider.fontPrimary.withOpacity(0.7), fontSize: FontSize.textSm),
                          leading: const Icon(
                            Icons.color_lens,
                            color: ThemeProvider.iconSecondary,
                            size: 40,
                          ),
                          onTap: () {
                            Util.toast("Coming soon..");
                          },
                        ),
                        ListTile(
                          title: Util.label("Contact",
                              color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
                          subtitle: Util.label("Reach out to us",
                              color: ThemeProvider.fontPrimary.withOpacity(0.7), fontSize: FontSize.textSm),
                          leading: const Icon(
                            Icons.contact_support,
                            color: ThemeProvider.iconSecondary,
                            size: 40,
                          ),
                          onTap: () {
                            Util.launchEmail(emailAddresses: ["rohitkeerthikanth@gmail.com","contact@prudhvisuraaj.me"],subject: "Contact:connect for admin");
                          },
                        ),
                        ListTile(
                          title: Util.label("Contributions",
                              color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
                          subtitle: Util.label(
                              "Check out code & make contributions.",
                              color: ThemeProvider.fontPrimary.withOpacity(0.7),
                              fontSize: FontSize.textSm),
                          leading: const Icon(
                            Ionicons.logo_github,
                            color: ThemeProvider.iconSecondary,
                            size: 40,
                          ),
                          onTap: () async {
                            //repository link
                            await Util.launchLink(
                                "https://github.com/GPSxtreme/gvpw_connect");
                          },
                        ),
                        ListTile(
                          title: Util.label("Developers",color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
                          leading: const Icon(
                            Ionicons.logo_android,
                            color: ThemeProvider.iconSecondary,
                            size: 40,
                          ),
                          subtitle: Util.label(
                              "Check out developers.",
                              color: ThemeProvider.fontPrimary.withOpacity(0.7),
                              fontSize: FontSize.textSm),
                          onTap: () {
                            Navigator.pushNamed(context, DevelopersPage.id);
                          },
                        ),
                        ListTile(
                          title: Util.label("Log out",
                              color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
                          subtitle: Util.label("logout from this device.",
                              color: ThemeProvider.fontPrimary.withOpacity(0.7), fontSize: FontSize.textSm),
                          leading: const Icon(
                            Ionicons.log_out,
                            color: ThemeProvider.iconSecondary,
                            size: 40,
                          ),
                          onTap: () async {
                            //sign out
                            bool? result = await Util.commonAlertDialog(context,
                                title: 'Logout?',
                                body: 'You will be redirected to login page.',
                                agreeLabel: 'Yes',
                                denyLabel: 'Cancel');
                            if(result == true){
                              AuthService.logOut(context);
                            }
                          },
                        ),
                        const SizedBox(height: 10,),

                      ],
                    ),
                  ),
                ),
                //main app bar
                MainAppBar(
                  scaffoldkey: _scaffoldKey,
                  backgroundColor: ThemeProvider.primary,
                  hideQuickAccessBar: true,
                  pageName: "Settings",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}