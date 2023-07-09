import 'dart:convert';
import 'package:gvpw_connect/providers/theme_provider.dart';
import 'package:gvpw_connect/utils/fcm_service.dart';
import 'package:gvpw_connect/utils/shared_preferences_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gvpw_connect/main.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'dart:io';

///[backgroundChannel] is used to communicate with the device via notifications from firebase when the device is in background.
const AndroidNotificationChannel backgroundChannel = AndroidNotificationChannel(
  'background_channel', // id
  'Background notifications', // title
  description: 'This channel is used for background notifications.',
  // description
  importance: Importance.high,
  playSound: true,
  enableLights: true,
  enableVibration: true,
  showBadge: true,
);

///[foregroundChannel] is used to communicate with the device via notifications from firebase when the device is in foreground.
const AndroidNotificationChannel foregroundChannel = AndroidNotificationChannel(
  'foreground_channel', // id
  'Foreground Notifications', // title
  description: 'This channel is used for foreground notifications.',
  // description
  importance: Importance.defaultImportance,
  playSound: true,
  enableLights: false,
  enableVibration: true,
  showBadge: false,
);

///[flutterLocalNotificationsPlugin] is local implementation to use flutter local notifications package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

///[_firebaseMessagingBackgroundHandler] is used to handle background messages when the app is not in use/foreground.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await notificationProvider.saveNotificationLocally(message);
}

class NotificationProvider extends ChangeNotifier with WidgetsBindingObserver {
  //constructor
  NotificationProvider() {
    // Register WidgetsBindingObserver
    WidgetsBinding.instance.addObserver(this);
  }

  List<dynamic> localNotifications = [];
  late bool isSeen;
  bool isOnNotificationPage = false;
  bool isAppActive = true;
  bool isFetchingMessages = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kDebugMode) {
      print(state);
    }
    if (state == AppLifecycleState.resumed) {
      isAppActive = true;
      if (!isFetchingMessages) {
        fetchMessages();
      }
    } else {
      isAppActive = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    // Unregister WidgetsBindingObserver
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> initialize() async {
    //fetch messages
    await fetchMessages();
    // Fetch whether the user has seen all notifications
    isSeen =
        SharedPreferencesService.sharedPreferences!.getBool('isSeen') ?? true;
  }

  Future<void> firebaseMessaging() async {
    //get permissions
    await FcmService.getFcmNotificationPermissions();
    //enable foreground messages
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    ///create [backgroundChannel] notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(backgroundChannel);

    ///create [foregroundChannel] notification channel
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(foregroundChannel);

    //handle messages on foreground.
    FirebaseMessaging.onMessage.listen((RemoteMessage notification) async {
      await saveNotificationLocally(notification);
      sendNotification(notification,foregroundChannel);
    });

    //fetch the same messages when the app gets opened.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage notification) async {
      await saveNotificationLocally(notification);
    });

    ///If the application has been opened from a terminated state via a RemoteMessage (containing a Notification), it will be returned, otherwise it will be null.
    // Once the RemoteMessage has been consumed, it will be removed and further calls to getInitialMessage will be null.
    // This should be used to determine whether specific notification interaction should open the app with a specific purpose (e.g. opening a chat message, specific screen etc).
    await FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null && message.notification != null) {
        await saveNotificationLocally(message);
      }
    });
    //handle messages on background.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> fetchMessages() async {
    if (isAppActive && !isFetchingMessages) {
      isFetchingMessages = true;
      localNotifications.clear();
      localNotifications = SharedPreferencesService.sharedPreferences!
          .getStringList('notifications')
          ?.map((msg) => jsonDecode(msg))
          .toList() ??
          [];
      // Sort messages according to the time they are received
      localNotifications.sort((a, b) => b["sentTime"].compareTo(a["sentTime"]));
      isFetchingMessages = false;
      if (kDebugMode) {
        print("notification provider : $localNotifications");
      }
      notifyListeners();
    }
  }

  void setMessagesSeen() {
    isSeen = true;
    notifyListeners();
  }

  void setMessagesNotSeen() {
    isSeen = false;
    notifyListeners();
  }

  void setIsOnNotificationsPage() {
    isOnNotificationPage = true;
    notifyListeners();
  }

  void resetIsOnNotificationsPage() {
    isOnNotificationPage = false;
    notifyListeners();
  }

  Future<void> clearAllLocalNotifications() async{
    await SharedPreferencesService.clearAllNotifications();
    localNotifications.clear();
    notifyListeners();
  }

  ///[sendNotification] is a common method used to send notifications when the app is either in foreground or background.
  Future<void> sendNotification(RemoteMessage message , AndroidNotificationChannel channel)async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      BigPictureStyleInformation? bigPictureStyleInformation;
      //handle if notification contains an image.
      if (notification.android!.imageUrl != null) {
        File file = await DefaultCacheManager().getSingleFile(notification.android!.imageUrl!);
        bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(file.path),
          largeIcon: const FilePathAndroidBitmap('@mipmap/ic_launcher'),
        );
      }
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: backgroundChannel.description,
                importance: channel.importance,
                color: ThemeProvider.primary,
                playSound: true,
                icon: '@mipmap/ic_launcher',
                largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
                styleInformation: bigPictureStyleInformation
            ),
          ));
    }
  }

  Future<void> saveNotificationLocally(RemoteMessage message) async {
    await SharedPreferencesService.waitForInitialization();
    List savedNotifications = SharedPreferencesService.sharedPreferences!
        .getStringList('notifications')
        ?.map((msg) => jsonDecode(msg))
        .toList() ??
        [];
    //check if the message already exists in the local storage
    //then add the message.
    if (savedNotifications.any((localMessage) => localMessage['messageId'] != message.messageId) ||
        savedNotifications.isEmpty) {
      savedNotifications.add(message.toMap());
    }
    await SharedPreferencesService.sharedPreferences!.setStringList(
        'notifications', savedNotifications.map((msg) => jsonEncode(msg)).toList());
    if (isOnNotificationPage) {
      //set isSeen shared preference to true
      await SharedPreferencesService.sharedPreferences!.setBool('isSeen', true);
      setMessagesSeen();
    } else {
      //set isSeen shared preference to false
      await SharedPreferencesService.sharedPreferences!
          .setBool('isSeen', false);
      setMessagesNotSeen();
    }
    await fetchMessages();
    notifyListeners();
  }

  ///removes the notification at given index of [localNotifications]
  Future<void> removeNotification(int index) async {
    // Remove the notification from the list
    notificationProvider.localNotifications.removeAt(index);
    // Update the SharedPreferences with the updated list of notifications
    await SharedPreferencesService.sharedPreferences!.setStringList(
      'notifications',
      notificationProvider.localNotifications
          .map((msg) => jsonEncode(msg))
          .toList(),
    );
    notifyListeners();
  }
}