import 'package:gvpw_connect/pages/settings_page.dart';
import 'package:gvpw_connect/pages/user_filled_surveys_page.dart';
import 'package:gvpw_connect/pages/user_profile_edit_page.dart';
import 'package:gvpw_connect/widgets/drawer_option_tile.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:gvpw_connect/pages/surveys_page.dart';
import '../providers/theme_provider.dart';
import '../providers/user_data_provider.dart';
import '../styles/styles.dart';
import '../utils/util.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 10,
      width: MediaQuery.of(context).size.width * 0.7,
      backgroundColor: ThemeProvider.primary,
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0, bottom: 20),
        child: Consumer<UserDataProvider>(
          builder: (context, userDataProvider, child) => Column(
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, UserProfileEditPage.id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      userDataProvider.profilePicture != null
                          ? CircleAvatar(
                        radius: 27,
                        backgroundImage:
                        FileImage(userDataProvider.profilePicture!),
                      )
                          : Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Icon(
                          Ionicons.person_circle_outline,
                          color: ThemeProvider.accent,
                          size: 65,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userDataProvider.userData["name"],
                              style: Styles.textStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: FontSize.textLg,
                                color: ThemeProvider.fontPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              userDataProvider.userData["rollNo"],
                              style: Styles.textStyle(
                                fontWeight: userDataProvider.isAdmin
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: FontSize.textSm,
                                color: userDataProvider.isAdmin
                                    ? ThemeProvider.fontSecondary
                                    : ThemeProvider.accent,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Divider(
                color: ThemeProvider.accent.withOpacity(0.1),
                indent: 10,
                endIndent: 10,
                thickness: 1.5,
              ),
              const SizedBox(
                height: 20,
              ),
              Util.listViewRenderer([
                DrawerOptionTile(
                  optionName: "Surveys",
                  icon: Ionicons.document,
                  action: () {
                    Util.navigateToScreen(
                      context,
                      SurveysPage.id,
                          (context) => const SurveysPage(),
                    );
                  },
                  listenForRoute: SurveysPage.id,
                ),
                DrawerOptionTile(
                  optionName: "Filled surveys",
                  icon: Icons.check,
                  action: () {
                    Util.navigateToScreen(
                      context,
                      UserFilledSurveysPage.id,
                          (context) => const UserFilledSurveysPage(),
                    );
                  },
                  listenForRoute: UserFilledSurveysPage.id,
                ),
                DrawerOptionTile(
                  optionName: "Settings",
                  icon: Icons.settings,
                  action: () {
                    Util.navigateToScreen(
                      context,
                      SettingsPage.id,
                          (context) => const SettingsPage(),
                    );
                  },
                  listenForRoute: SettingsPage.id,
                ),
              ], verticalGap: 0, horizontalGap: 0),
            ],
          ),
        ),
      ),
    );
  }
}