import 'dart:developer';

import 'package:chat_app/Widget/authWidgetBuilder.dart';
import 'package:chat_app/modal/user.dart';

import 'package:chat_app/services/authMethods.dart';
import 'package:chat_app/services/notification.dart';
import 'package:chat_app/services/utilities.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Widget/authWidget.dart';
import 'Widget/authenticate.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  log("backgroundHandler: " + message.data.toString());
  LocalNotificationService.createanddisplaynotification(message);

}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  final PendingDynamicLinkData initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  log("Initial Link: ${initialLink.toString()}");
  if (initialLink != null) {
    log("Deep Link: ${initialLink.link.toString()}");
  }
  runApp(MyApp(initialLink: initialLink,));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final PendingDynamicLinkData initialLink;
  MyApp({this.initialLink});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthMethods>(create: (context) => AuthMethods()),
        ChangeNotifierProvider<MyUser>(create: (context) => MyUser()),
        ChangeNotifierProvider<Utilities>(
            create: (context) => Utilities(referralLink: initialLink)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Authenticate(),
      ),
    );
  }
}
