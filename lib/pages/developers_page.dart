import 'package:flutter/material.dart';
import 'package:gvpw_connect/widgets/developer_profile_tile.dart';
import '../providers/theme_provider.dart';
import '../utils/util.dart';

class DevelopersPage extends StatelessWidget {
  const DevelopersPage({Key? key}) : super(key: key);
  static const id = 'developers_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Util.commonAppBar(context, name: "Contributions",backgroundColor: ThemeProvider.primary),
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