// ignore_for_file: use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import '../styles/styles.dart';
import '../utils/util.dart';

class NotificationTile extends StatefulWidget {
  const NotificationTile(
      {Key? key, required this.messageData, required this.messageIndex})
      : super(key: key);
  final Map messageData;
  final int messageIndex;

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  Future<void> notificationActions() => showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        color: ThemeProvider.primary,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: Icon(
                Icons.delete,
                color: ThemeProvider.tertiary,
              ),
              title: Text(
                'Delete Notification',
                style: Styles.textStyle(color: ThemeProvider.fontPrimary,fontWeight: FontWeight.w500),
              ),
              onTap: () async {
                // Perform deletion logic here
                Navigator.pop(context); // Close the bottom sheet
                bool? result = await Util.commonAlertDialog(context,
                    title: 'Delete Notification',
                    body:
                    'Are you sure you want to delete this notification?',
                    agreeLabel: 'Delete',
                    denyLabel: 'Cancel');
                if (result != null && result) {
                  notificationProvider
                      .removeNotification(widget.messageIndex);
                  Util.toast("Message deleted");
                }
              },
            ),
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        bool? result = await Util.commonAlertDialog(context,
            title: 'Delete Notification',
            body: 'Are you sure you want to delete this notification?',
            agreeLabel: 'Delete',
            denyLabel: 'Cancel');
        return result;
      },
      onDismissed: (_) async {
        //remove notification
        notificationProvider.removeNotification(widget.messageIndex);
        Util.toast("Notification deleted");
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Util.label("Delete",
                fontWeight: FontWeight.bold,
                color: ThemeProvider.fontPrimary,
                fontSize: FontSize.textLg),
            const SizedBox(
              width: 10,
            ),
            const Icon(Icons.delete, color: ThemeProvider.fontPrimary),
          ],
        ),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        title: Util.label(widget.messageData["notification"]["title"] ?? '',
            color: ThemeProvider.accent, fontSize: FontSize.textLg),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            Util.label(widget.messageData["notification"]["body"] ?? '',
                color: ThemeProvider.fontPrimary, fontSize: FontSize.textSm),
            const SizedBox(
              height: 5,
            ),
            Util.label(
                Util.formatDateTime(DateTime.fromMillisecondsSinceEpoch(
                    widget.messageData["sentTime"])
                    .toLocal()),
                color: ThemeProvider.fontPrimary.withOpacity(0.7),
                fontSize: FontSize.textXs)
          ],
        ),
        trailing: null,
        leading:
        widget.messageData['notification']['android']['imageUrl'] != null
            ? SizedBox(
            height: 60,
            width: 60,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                    imageUrl: widget.messageData['notification']
                    ['android']['imageUrl'])))
            : null,
        onLongPress: () async {
          await notificationActions();
        },
      ),
    );
  }
}