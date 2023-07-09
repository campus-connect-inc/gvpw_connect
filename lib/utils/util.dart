import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../providers/route_provider.dart';
import '../styles/styles.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

class Util {
  static void toast(String msg) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: ThemeProvider.secondary,
        textColor: ThemeProvider.accent,
        fontSize: 16.0);
  }
  /// checks for update from android play store.
  static Future<bool> checkForUpdate() async {
    try{
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate();
        return true;
      }
    }catch (e){
      if(kDebugMode){
        print("Error : $e");
      }
    }
    return false;
  }
  ///A standard ListViewRenderer.
  static Widget listViewRenderer(List list,
      {required double verticalGap, required double horizontalGap}) {
    if (list.isNotEmpty) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(
                vertical: verticalGap, horizontal: horizontalGap),
            child: list[index],
          );
        },
      );
    } else {
      return const Text(
        "no results",
        style: TextStyle(color: ThemeProvider.fontPrimary),
      );
    }
  }

  ///A standard GridViewRenderer.
  static Widget gridViewRenderer(List list,
      {required double horizontalPadding,
        required double verticalPadding,
        required int crossAxisCount,
        required double crossAxisSpacing,
        required double mainAxisSpacing}) {
    if (list.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding, vertical: verticalPadding),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return list[index];
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: crossAxisSpacing,
              mainAxisSpacing: mainAxisSpacing),
        ),
      );
    } else {
      return const Text(
        "no results",
        style: TextStyle(color: ThemeProvider.fontPrimary),
      );
    }
  }

  static AppBar commonAppBar(BuildContext context,
      {required String name,
        bool? centerTitle,
        IconData? leadingIcon,
        double? leadingIconSize,
        Color? leadingIconColor,
        bool? disableBackFunction,
        void Function()? leadingIconAction,
        Color? backgroundColor,
        List<Widget>? actions}) {
    return AppBar(
      backgroundColor: backgroundColor ?? ThemeProvider.primary,
      elevation: 0,
      centerTitle: centerTitle,
      actions: actions,
      leadingWidth: 40.0,
      title: Text(
        name,
        style: Styles.textStyle(
            fontSize: FontSize.textXl,
            fontWeight: FontWeight.bold,
            color: ThemeProvider.accent),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: GestureDetector(
          onTap: leadingIconAction ??
                  () {
                if (disableBackFunction != null && !disableBackFunction) {
                  Navigator.pop(context);
                }
                if (disableBackFunction == null) {
                  Navigator.pop(context);
                }
              },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(leadingIcon ?? Ionicons.chevron_back,
                color: leadingIconColor ?? ThemeProvider.accent,
                size: leadingIconSize ?? 30),
          ),
        ),
      ),
    );
  }

  static void navigateToScreen(BuildContext context, String routeName,
      Widget Function(BuildContext) builder) {
    bool isAlreadyPresent = Navigator.canPop(context);
    if (!isAlreadyPresent) {
      Navigator.pushNamed(context, routeName);
      Provider.of<RouteNameProvider>(context, listen: false)
          .setCurrentRouteName(routeName);
    } else {
      Navigator.popUntil(context, ModalRoute.withName(routeName));
      Provider.of<RouteNameProvider>(context, listen: false)
          .setCurrentRouteName(routeName);
      // Call the builder function to rebuild the widget tree
      // and display the screen at the top of the stack
      Navigator.push(context, MaterialPageRoute(builder: builder));
    }
  }


  static String formatTimestamp(Timestamp date) {
    return DateFormat('MMMM d, y EEEE').format(date.toDate());
  }
  static String formatDateTime(DateTime date){
    return DateFormat('MMMM d, y EEEE hh:mm:ss a').format(date);
  }
  static Widget label(String title,
      {double? fontSize,
        Color? color,
        FontWeight? fontWeight,
        TextOverflow? overflow,
        TextAlign? textAlign,
        int? maxLines}) =>
      Text(title,
          style: Styles.textStyle(
              color: color ?? ThemeProvider.fontPrimary.withOpacity(0.85),
              fontSize: fontSize ?? FontSize.textBase,
              fontWeight: fontWeight ?? FontWeight.w600),
          overflow: overflow,
          textAlign: textAlign,
          maxLines: maxLines);

  static Widget textField(
      {TextEditingController? controller,
        void Function(String)? onChanged,
        int? maxLines,
        bool? readOnly,
        String? initialValue,
        TextInputType? inputType,
        double? fontSize}) =>
      TextFormField(
        readOnly: readOnly ?? false,
        maxLines: maxLines,
        keyboardType: inputType,
        initialValue: initialValue,
        cursorColor: ThemeProvider.secondary,
        style: Styles.textStyle(
            color: ThemeProvider.accent,
            fontWeight: FontWeight.w600,
            fontSize: fontSize ?? FontSize.textLg),
        textAlign: TextAlign.start,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
            isDense: true,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(color: ThemeProvider.tertiary, width: 2.0)),
            focusedBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(color: ThemeProvider.accent, width: 2.0))),
      );

  ///Launches the given url
  static Future<void> launchLink(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri,mode: LaunchMode.externalApplication);
    } catch (e) {
      Util.toast(e.toString());
    }
  }

  static Future<void> launchEmail({required List<String> emailAddresses, String? subject, String? body}) async {
    final String emails = emailAddresses.join(',');
    String emailSubject = Uri.encodeComponent(subject ?? "");
    String emailBody = Uri.encodeComponent(body ?? "");
    String emailUrl = "mailto:$emails?subject=$emailSubject&body=$emailBody";
    try {
      await launchUrlString(emailUrl);
    } catch(e) {
      Util.toast("Error redirecting to gmail.");
    }
  }

  static Future<bool?> commonAlertDialog(BuildContext context,
      {String? title,
        String? body,
        required String agreeLabel,
        required String denyLabel,
        Color? agreeButtonColor,
        Color? denyButtonColor,
        Color? titleColor,
        Color? bodyColor,
      }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18.0))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25,vertical: 25),
        backgroundColor: ThemeProvider.commonAlertBox,
        title: Text(title ?? '',style: Styles.textStyle(color: titleColor ?? ThemeProvider.accent,fontSize: FontSize.textLg,fontWeight: FontWeight.w600),),
        content: Text(body ?? '',style: Styles.textStyle(color:bodyColor ?? ThemeProvider.fontPrimary,fontSize: FontSize.textBase,fontWeight: FontWeight.w600),),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: GestureDetector(
                  onTap: (){
                    Navigator.of(context).pop(true);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(agreeLabel ,style: Styles.textStyle(color:agreeButtonColor ?? Colors.red,fontSize: FontSize.textBase,fontWeight: FontWeight.w600),),
                  ),
                ),
              ),
              Divider(
                color: ThemeProvider.accent.withOpacity(0.25),
                indent: 10,
                endIndent: 10,
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(denyLabel,style: Styles.textStyle(color: denyButtonColor ?? ThemeProvider.fontPrimary,fontSize: FontSize.textBase,fontWeight: FontWeight.w600),),
                  ),
                ),
              ),
              const SizedBox(height: 10,)
            ],
          ),
        ],
      ),
    );
  }

  static Widget sectionName(String name) => Column(
    children: [
      Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ThemeProvider.secondary),
        child: Row(
          children: [
            Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.circle_rounded,
                color: ThemeProvider.accent,
                size: 15,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              name,
              style: Styles.textStyle(
                  color: ThemeProvider.accent,
                  fontSize: FontSize.textXl,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      const SizedBox(
        height: 10,
      ),
    ],
  );

  static Widget categoryLabel(String text,{double? fontSize}) => Container(
    padding: const EdgeInsets.only(bottom: 7.0),
    decoration: BoxDecoration(
      border: Border(
          bottom : BorderSide(color: ThemeProvider.tertiary,width: 5.0)
      ),
    ),
    child: Util.label(text,
        fontSize: fontSize ?? FontSize.text2Xl,
        color: ThemeProvider.fontPrimary,
        fontWeight: FontWeight.w700),
  );

  static Widget tradeMark() {
    return Column(
      children: [
        Text(
          "By\nGPSxtreme",
          style: GoogleFonts.mansalva(color: ThemeProvider.fontPrimary.withOpacity(0.54)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}