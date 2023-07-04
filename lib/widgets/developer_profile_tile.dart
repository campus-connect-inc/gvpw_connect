import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_data_provider.dart';
import '../styles/styles.dart';
import '../utils/util.dart';


class DeveloperProfileTile extends StatefulWidget {
  const DeveloperProfileTile({super.key, required this.profileUrl, required this.devName, required this.discordLink, required this.instagramLink, required this.githubLink, required this.linkedInLink});
  final String profileUrl;
  final String devName;
  final String discordLink;
  final String instagramLink;
  final String githubLink;
  final String linkedInLink;
  @override
  State<DeveloperProfileTile> createState() => _DeveloperProfileTileState();
}

class _DeveloperProfileTileState extends State<DeveloperProfileTile> {

  pickOptionsTile(
  {
    required IconData icon,
    required String name,
    required void Function()? onTap
}
      ){
    return ListTile(
      leading: Icon(
        icon,
        color: ThemeProvider.fontPrimary,
      ),
      trailing: const Icon(Icons.open_in_browser,color: Colors.white,),
      title: Text(
        name,
        style: Styles.textStyle(
            color: ThemeProvider.accent,
            fontWeight: FontWeight.w500,
            fontSize: FontSize.textLg),
      ),
      onTap: onTap,
    );
  }

  void _showPickOptions() => showModalBottomSheet(
    backgroundColor: ThemeProvider.primary,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            pickOptionsTile(icon: Ionicons.logo_github,
                name: "Github",
                onTap: () async {
                  Util.launchLink(widget.githubLink);
                }),
            pickOptionsTile(icon: Ionicons.logo_linkedin,
                name: "LinkedIn",
                onTap: () async {
                  Util.launchLink(widget.linkedInLink);
                }),
            pickOptionsTile(icon: Ionicons.logo_instagram,
                name: "Instagram",
                onTap: () async {
                  Util.launchLink(widget.instagramLink);
                }),
            pickOptionsTile(icon: Ionicons.logo_discord,
                name: "Discord",
                onTap: () async {
                  Util.launchLink(widget.discordLink);
                }),
          ],
        ),
      );
    },
  );
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5,horizontal: 15),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
            widget.profileUrl,
            headers: {
              'Authorization':
              'Bearer ${Provider.of<UserDataProvider>(context, listen: false).userAuthToken}'
            }),
        radius: 25,
      ),
      title: Util.label(widget.devName,color: Colors.white,fontSize: FontSize.textLg),
      subtitle: Util.label("Developer",color: Colors.white.withOpacity(0.6)),
      trailing: const Icon(Icons.link,color: Colors.white,size: 25.0,),
      onTap: _showPickOptions,
    );
  }
}
