import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../providers/theme_provider.dart';
import '../styles/styles.dart';
import '../utils/util.dart';

class CheckUpdateTile extends StatefulWidget {
  const CheckUpdateTile({super.key});

  @override
  State<CheckUpdateTile> createState() => _CheckUpdateTileState();
}

class _CheckUpdateTileState extends State<CheckUpdateTile> {
  bool _isCheckingForUpdate = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Util.label("Update",
          color: ThemeProvider.fontPrimary, fontSize: FontSize.textLg),
      subtitle: Util.label("Check for latest updates.",
          color: ThemeProvider.fontPrimary.withOpacity(0.7), fontSize: FontSize.textSm),
      leading: !_isCheckingForUpdate ? const Icon(
        Icons.update,
        color: ThemeProvider.iconSecondary,
        size: 40,
      ) : Container(
        width: 40, // same as the Icon size
        alignment: Alignment.centerLeft, // align to the left
        child: const SpinKitDualRing(color: ThemeProvider.iconSecondary,size: 30,),
      ),
      onTap: () async {
        // start checking for updates
        setState(() {
          _isCheckingForUpdate = true;
        });
        await Util.checkForUpdate().then((isAvailable){
          setState(() {
            _isCheckingForUpdate = false;
          });
          if(isAvailable){
            Util.toast("Update available");
          } else{
            Util.toast("No updates available");
          }
        });
      },
    );
    ;
  }
}