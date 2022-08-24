import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final AndroidNotificationChannelGroup channelGroup =
      AndroidNotificationChannelGroup('chatAppGroup', 'chatAppGroupChannel');

  static void initialize() async {
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("ic_stat_chaticon"),
    );
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        .createNotificationChannelGroup(channelGroup);

    _notificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String id) async {
        print("onSelectNotification");
        if (id.isNotEmpty) {
          print("Router Value1234 $id");

          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (context) => DemoScreen(
          //       id: id,
          //     ),
          //   ),
          // );

        }
      },
    );
  }

  static Future<NotificationDetails> generateNotificationDetails(
      RemoteMessage message) async {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        "chatApp",
        "chatAppchannel",
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: MessagingStyleInformation(
          Person(
              name: message.data["senderName"],
              icon: message.data["senderProfileURL"] == ""
                  ? null
                  : ByteArrayAndroidIcon.fromBase64String(
                      await _base64encodedImage(
                          message.data["senderProfileURL"]))),
          messages: <Message>[
            Message(
                message.data["isPhoto"] == "false"
                    ? message.data["message"]
                    : "${message.data["senderName"]} has sent you a photo",
                DateTime.now(),
                null),
          ],
        ),
        color: Color(0xFF4A13EA),
      ),
    );
  }

  static void createanddisplaynotification(RemoteMessage message) async {
    log("Local Notification create and display called");
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails =
          await generateNotificationDetails(message);
      await _notificationsPlugin.show(
        id,
        "New Message",
        "You have a new message",
        notificationDetails,
        payload: message.data['_id'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  static Future<String> _base64encodedImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    final String base64Data = base64Encode(response.bodyBytes);
    return base64Data;
  }
}
