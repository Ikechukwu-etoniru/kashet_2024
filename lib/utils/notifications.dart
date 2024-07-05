import 'dart:math';

// import 'package:awesome_notifications/awesome_notifications.dart';

class Notifications {
  static const basicChannelKey = 'basic_channel';
  static const basicChannelName = 'Basic Notification';
  static const basicChannelDescription = '';

  static int createUniqueId() {
    Random rand = Random();
    return rand.nextInt(10000);
  }

  static Future notifyUser(
      {required String title, required String body}) async {
    // await AwesomeNotifications().createNotification(
    //   content: NotificationContent(
    //     id: createUniqueId(),
    //     channelKey: Notifications.basicChannelKey,
    //     title: title,
    //     body: body,
    //     notificationLayout: NotificationLayout.Default,
    //   ),
    // );
  }
}
