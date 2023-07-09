import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:gvpw_connect/providers/user_data_provider.dart';
import 'package:gvpw_connect/widgets/profile_picture_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../styles/styles.dart';
import '../utils/util.dart';

class UserProfileEditPage extends StatefulWidget {
  const UserProfileEditPage({Key? key}) : super(key: key);
  static const id = "user_profile_edit_page";

  @override
  State<UserProfileEditPage> createState() => _UserProfileEditPageState();
}

class _UserProfileEditPageState extends State<UserProfileEditPage> {
  double tileGap = 25.0;
  double tileContentGap = 5.0;
  bool isUpdating = false;
  late UserDataProvider userDataProvider;

  Widget label(String title, {double? fontSize, Color? color}) => Text(
    title,
    style: Styles.textStyle(
        color: color ?? Colors.white.withOpacity(0.85),
        fontSize: fontSize ?? FontSize.textBase,
        fontWeight: FontWeight.w700),
  );

  Future<void> onUpdate(UserDataProvider userDataProvider) async {
    setState(() {
      isUpdating = true;
    });
    try {
      bool changesMade = false;
      //update user profile settings
      //1.check if user selected a new profile pic,if yes upload it.
      if (userDataProvider.newProfilePicture != null) {
        await userDataProvider.uploadProfilePicture();
        changesMade = true;
      }
      //check if at least one additional information is filled and also check if they are equal to the userData map,
      //if equal do not push the changes.
      if (userDataProvider.personalEmail.trim().isNotEmpty ||
          userDataProvider.secondaryPhoneNo.trim().isNotEmpty ||
          userDataProvider.careTakerPhoneNo.trim().isNotEmpty) {
        //update additional information if filled.
        Map<String, dynamic> data = {};
        if (userDataProvider.personalEmail.trim().isNotEmpty) {
          data["personalEmail"] = userDataProvider.personalEmail;
        }
        if (userDataProvider.secondaryPhoneNo.trim().isNotEmpty) {
          data["secondaryPhoneNo"] = userDataProvider.secondaryPhoneNo;
        }
        if (userDataProvider.careTakerPhoneNo.trim().isNotEmpty) {
          data["careTakerPhoneNo"] = userDataProvider.careTakerPhoneNo;
        }
        await userDataProvider.updateUserData(data);
        changesMade = true;
      }
      if (!changesMade) {
        Util.toast("No changes made");
      } else {
        Util.toast("Update successful 🚀");
      }
    } catch (e) {
      Util.toast("Error : $e");
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData device = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        return !isUpdating;
      },
      child: Scaffold(
        appBar: Util.commonAppBar(context,
            disableBackFunction: isUpdating,
            name: "Edit profile",
            backgroundColor: ThemeProvider.secondary.withOpacity(0.75),
        ),
        backgroundColor: ThemeProvider.primary,
        body: Consumer<UserDataProvider>(
          builder: (context, userDataProvider, child) => Stack(
            children: [
              //pick user profile picture
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      elevation: 8,
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(45),
                          bottomRight: Radius.circular(45)),
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: device.size.width,
                          minHeight: device.size.height * 0.30,
                        ),
                        decoration: BoxDecoration(
                            color: ThemeProvider.secondary,
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(45),
                                bottomRight: Radius.circular(45)),
                            gradient: LinearGradient(
                                end: FractionalOffset.bottomCenter,
                                begin: FractionalOffset.topCenter,
                                colors: [
                                  ThemeProvider.secondary.withOpacity(0.75),
                                  ThemeProvider.secondary.withOpacity(0.50),
                                  ThemeProvider.secondary.withOpacity(0.30),
                                ],
                                stops: const [
                                  0.16,
                                  0.64,
                                  0.96,
                                ])),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ProfilePicturePicker(
                                userDataProvider: userDataProvider,
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Text(
                                userDataProvider.userData["name"],
                                style: Styles.textStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: FontSize.textXl),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              SelectableText(
                                userDataProvider.userData["rollNo"],
                                style: Styles.textStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w500,
                                    fontSize: FontSize.textBase),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: SizedBox(
                        height: device.size.height * 0.57,
                        child: NotificationListener<OverscrollIndicatorNotification>(
                          onNotification: (overScroll) {
                            overScroll.disallowIndicator();
                            return true;
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Util.categoryLabel("Primary\nInformation"),
                                SizedBox(
                                  height: tileGap + 15,
                                ),
                                label("Full name"),
                                SizedBox(
                                  height: tileContentGap,
                                ),
                                Util.textField(
                                    readOnly: true,
                                    initialValue: userDataProvider.userData["name"]),
                                SizedBox(
                                  height: tileGap,
                                ),
                                label("College email"),
                                SizedBox(
                                  height: tileContentGap,
                                ),
                                Util.textField(
                                    readOnly: true,
                                    initialValue: userDataProvider.userData["email"]),
                                SizedBox(
                                  height: tileGap,
                                ),
                                label("Department"),
                                SizedBox(
                                  height: tileContentGap,
                                ),
                                Util.textField(
                                    readOnly: true,
                                    initialValue: userDataProvider.userData["dept"]),
                                SizedBox(
                                  height: tileGap,
                                ),
                                label("Primary phone number"),
                                SizedBox(
                                  height: tileContentGap,
                                ),
                                Util.textField(
                                    readOnly: true,
                                    initialValue:
                                    "+91${userDataProvider.userData["phoneNo"]}"),
                                SizedBox(
                                  height: tileGap + 15,
                                ),
                                Util.categoryLabel("Additional\nInformation"),
                                SizedBox(
                                  height: tileGap + 15,
                                ),
                                label("Personal email"),
                                SizedBox(
                                  height: tileContentGap,
                                ),
                                Util.textField(
                                    inputType: TextInputType.emailAddress,
                                    initialValue:
                                    userDataProvider.userData["personalEmail"] ??
                                        "",
                                    onChanged: (email) {
                                      userDataProvider.setPersonalEmail(email);
                                    }),
                                SizedBox(
                                  height: tileGap,
                                ),
                                label("Secondary phone number"),
                                SizedBox(
                                  height: tileContentGap,
                                ),
                                Util.textField(
                                    inputType:
                                    const TextInputType.numberWithOptions(),
                                    initialValue: userDataProvider
                                        .userData["secondaryPhoneNo"] ??
                                        "",
                                    onChanged: (phoneNo) {
                                      //update Secondary phone number.
                                      userDataProvider.setSecondaryPhoneNo(phoneNo);
                                    }),
                                SizedBox(
                                  height: tileGap,
                                ),
                                label("Parent/guardian phone number"),
                                SizedBox(
                                  height: tileContentGap,
                                ),
                                Util.textField(
                                    inputType:
                                    const TextInputType.numberWithOptions(),
                                    initialValue: userDataProvider
                                        .userData["careTakerPhoneNo"] ??
                                        "",
                                    onChanged: (phoneNo) {
                                      //update careTaker phone number.
                                      userDataProvider.setCareTakerPhoneNo(phoneNo);
                                    }),
                                SizedBox(
                                  height: tileGap,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: !isUpdating ? () async {
                                          await onUpdate(userDataProvider);
                                        } : null,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 0),
                                          backgroundColor: ThemeProvider.accent,
                                          shadowColor: Colors.black45,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 9, vertical: 3),
                                          child: !isUpdating
                                              ? Text(
                                            "Update",
                                            style: Styles.textStyle(
                                                color: ThemeProvider.primary,
                                                fontWeight: FontWeight.w700,
                                                fontSize: FontSize.textLg),
                                          )
                                              : SpinKitCircle(
                                            color: ThemeProvider.accent,
                                            size: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              //other details
            ],
          ),
        ),
      ),
    );
  }
}