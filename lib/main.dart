import 'dart:developer';

import 'package:chat_app/Widget/authWidgetBuilder.dart';
import 'package:chat_app/modal/user.dart';
import 'package:chat_app/modal/utilities.dart';

import 'package:chat_app/services/authMethods.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Widget/authWidget.dart';
import 'Widget/authenticate.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     'This channel is used for important notifications.', // description
//     importance: Importance.high,
//     playSound: true);

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final PendingDynamicLinkData initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  log("Initial Link: ${initialLink.toString()}");
  if(initialLink!=null){
    log("Deep Link: ${initialLink.link.toString()}");
  }
  
  runApp(MyApp(initialLink: initialLink,));
}


class MyApp extends StatelessWidget {
  final PendingDynamicLinkData initialLink;
  MyApp({this.initialLink});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthMethods>(create: (context) => AuthMethods()),
        ChangeNotifierProvider<MyUser>(create: (context) => MyUser()),
        ChangeNotifierProvider<Utilities>(create: (context) => Utilities(referralLink: initialLink)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Authenticate(),
      ),
    );
  }
}

