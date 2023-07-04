import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../providers/theme_provider.dart';
import '../styles/styles.dart';
import '../utils/util.dart';

class DevelopersInfo extends StatelessWidget {
  const DevelopersInfo({Key? key}) : super(key: key);
  static const id = 'developers_page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Util.commonAppBar(context, name: "Developers",backgroundColor: ThemeProvider.primary),
        backgroundColor: ThemeProvider.primary,
        body:Column(
          children: [
            const SizedBox(height: 30,),
            ListTile(
              title: Row(
                children: [
                  Util.label("Prudhvi Suraaj : ",color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
                  IconButton(
                    icon:const Icon(Ionicons.logo_instagram),
                    color: ThemeProvider.iconSecondary,
                    onPressed:() async{
                      await Util.launchLink('https://www.instagram.com/gps_xtreme');
                    },
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon:const Icon(Ionicons.logo_linkedin),
                    color: ThemeProvider.iconSecondary,
                    onPressed:() async{
                      await Util.launchLink('https://www.linkedin.com/in/prudhvi-suraaj-461155227/');
                    },
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon:const Icon(Ionicons.logo_discord),
                    color: ThemeProvider.iconSecondary,
                    onPressed:() async{
                      await Util.launchLink('https://www.discordapp.com/users/451709285454446592');
                    },
                    splashRadius: 20,
                  ),
                ],
              ),
              leading: ClipOval(
                  child: Image.asset('assets/dev_profiles/dev1.jpg',width: 50,height: 50,)
              ),
            ),
            const SizedBox(height: 40,),
            ListTile(
              title: Row(
                children: [
                  Util.label("Rohit KK              : ",color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
                  const SizedBox(width: 0,),
                  IconButton(
                    icon:const Icon(Ionicons.logo_instagram),
                    color: ThemeProvider.iconSecondary,
                    onPressed: () async{
                      await Util.launchLink('https://www.instagram.com/_rohit_kk_');
                    },
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon:const Icon(Ionicons.logo_linkedin),
                    color: ThemeProvider.iconSecondary,
                    onPressed:() async{
                      await Util.launchLink('https://www.linkedin.com/in/keerthikanth-rohit-a-794506251/');
                    },
                    splashRadius: 20,
                  ),
                  IconButton(
                    icon:const Icon(Ionicons.logo_discord),
                    color: ThemeProvider.iconSecondary,
                    onPressed:() async{
                      await Util.launchLink('https://www.discordapp.com/users/843176213090140182');
                    },
                    splashRadius: 20,
                  ),
                ],
              ),
              leading: ClipOval(
                  child: Image.asset('assets/dev_profiles/dev2.jpg',width: 50,height: 50,)
              ),
            ),
          ],
        )
    );
  }
}