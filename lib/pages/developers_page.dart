import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gvpw_connect/widgets/developer_profile_tile.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../providers/theme_provider.dart';
import '../styles/styles.dart';
import '../utils/util.dart';
import '../widgets/main_app_bar.dart';

class DevelopersPage extends StatelessWidget {
  DevelopersPage({Key? key}) : super(key: key);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const id = 'developers_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Util.commonAppBar(context, name: "Developers",backgroundColor: ThemeProvider.primary),
        backgroundColor: ThemeProvider.primary,
        body:const Column(
          children: [
            SizedBox(height: 10,),
            DeveloperProfileTile(
                profileUrl: "https://firebasestorage.googleapis.com/v0/b/campus-connect-inc.appspot.com/o/developerProfiles%2Fprudhvi-dev-profile.jpeg?alt=media&token=ea57a394-4534-4b22-8cce-e760f6f332fd",
                devName: "Prudhvi suraaj",
                discordLink: "https://www.discordapp.com/users/451709285454446592",
                instagramLink: "https://www.instagram.com/gps_xtreme",
                githubLink: "https://github.com/GPSxtreme",
                linkedInLink: "https://www.linkedin.com/in/prudhvi-suraaj-461155227/"),
            DeveloperProfileTile(
                profileUrl: "https://firebasestorage.googleapis.com/v0/b/campus-connect-inc.appspot.com/o/developerProfiles%2Frohit-dev-profile.jpeg?alt=media&token=bb7ff7a0-2985-460b-b0ef-231e877f53fb",
                devName: "Keerthikanth Rohit",
                discordLink: "https://www.discordapp.com/users/843176213090140182",
                instagramLink: "https://www.instagram.com/_rohit_kk_",
                githubLink: "https://github.com/Rohit-KK15",
                linkedInLink: "https://www.linkedin.com/in/keerthikanth-rohit-a-794506251/"),
          ],
        )
    );
  }
}