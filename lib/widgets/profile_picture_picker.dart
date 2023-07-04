// ignore_for_file: constant_identifier_names, use_build_context_synchronously
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:gvpw_connect/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import '../styles/styles.dart';

//Image quality constant
///Defines the percent of quality of the original picked image.
const IMAGE_QUALITY = 100;
const IMAGE_HEIGHT = 550.0;
const IMAGE_WIDTH = 550.0;

class ProfilePicturePicker extends StatefulWidget {
  const ProfilePicturePicker({Key? key, required this.userDataProvider})
      : super(key: key);
  final UserDataProvider userDataProvider;
  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  File? _imageFile;

  void removeImageFile() => setState(() {
    _imageFile = null;
  });

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: IMAGE_QUALITY,
        maxHeight: IMAGE_HEIGHT,
        maxWidth: IMAGE_WIDTH);
    widget.userDataProvider.setProfilePicture(File(pickedFile!.path));
    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }

  void showPickOptions() => showModalBottomSheet(
    backgroundColor: ThemeProvider.primary,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: ThemeProvider.fontPrimary,
              ),
              title: Text(
                'Take a photo',
                style: Styles.textStyle(
                    color: ThemeProvider.accent,
                    fontWeight: FontWeight.w500,
                    fontSize: FontSize.textLg),
              ),
              onTap: () {
                _pickImage(ImageSource.camera);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.image,
                color: ThemeProvider.fontPrimary,
              ),
              title: Text(
                'Choose from gallery',
                style: Styles.textStyle(
                    color: ThemeProvider.accent,
                    fontWeight: FontWeight.w500,
                    fontSize: FontSize.textLg),
              ),
              onTap: () {
                _pickImage(ImageSource.gallery);
                Navigator.of(context).pop();
              },
            ),
            if (widget.userDataProvider.profilePicture != null)
              DeleteOptionTile(userDataProvider: widget.userDataProvider, removeImageFile: removeImageFile)
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Consumer<UserDataProvider>(
      builder: (context, userDataProvider, child) => Stack(
        children: [
          Material(
            color: Colors.transparent,
            elevation: 10,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: showPickOptions,
                child: CircleAvatar(
                  radius: 65.0,
                  backgroundColor: ThemeProvider.fontSecondary.withOpacity(0.7),
                  backgroundImage: (_imageFile != null)
                      ? FileImage(_imageFile!)
                      : (userDataProvider.profilePicture != null)
                      ? FileImage(userDataProvider.profilePicture!)
                      : null,
                  child: (_imageFile == null &&
                      userDataProvider.profilePicture == null)
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Ionicons.person_add,
                          size: 60,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Add picture",
                          style: Styles.textStyle(
                              fontSize: FontSize.textSm,
                              color: ThemeProvider.fontPrimary,
                              fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  )
                      : null,
                )),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              elevation: 5.0,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: showPickOptions,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ThemeProvider.accent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      Icons.edit,
                      color: ThemeProvider.primary,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteOptionTile extends StatefulWidget {
  const DeleteOptionTile({super.key, required this.userDataProvider, required this.removeImageFile});
  final UserDataProvider userDataProvider;
  final void Function() removeImageFile;
  @override
  State<DeleteOptionTile> createState() => _DeleteOptionTileState();
}

class _DeleteOptionTileState extends State<DeleteOptionTile> {
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: !isDeleting
          ? const Icon(
        Icons.delete,
        color: ThemeProvider.fontPrimary,
      )
          : const SizedBox(
          height: 25,
          width: 25,
          child: SpinKitCircle(
            color: ThemeProvider.fontPrimary,
            size: 25,
          )),
      title: Text(
        !isDeleting ? 'Remove' : 'Removing...',
        style: Styles.textStyle(
            color: ThemeProvider.accent,
            fontWeight: FontWeight.w500,
            fontSize: FontSize.textLg),
      ),
      onTap: () async {
        setState(() {
          isDeleting = true;
        });
        await widget.userDataProvider.removeProfilePicture();
        setState(() {
          isDeleting = false;
        });
        widget.removeImageFile();
        Navigator.of(context).pop();
      },
    );
  }
}