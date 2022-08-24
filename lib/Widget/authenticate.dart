import 'dart:developer';

import 'package:chat_app/Pages/chatRoomScreen.dart';
import 'package:chat_app/Pages/signin.dart';
import 'package:chat_app/Pages/splashScreen.dart';
import 'package:chat_app/modal/notificationModel.dart';
import 'package:chat_app/modal/user.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/notification.dart';

class Authenticate extends StatefulWidget {
  Authenticate({Key key}) : super(key: key);

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  

  @override
  void initState() {
    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method
    FirebaseMessaging.instance.getInitialMessage().then(
      (RemoteMessage message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          setState(() {
            NotificationModel.messages.add(message);
          });
          print("New Notification");
          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );
   
    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          setState(() {
            NotificationModel.messages.add(message);
          });
          print(message.notification.title);
          print(message.notification.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final User user = snapshot.data;

          if (user != null) {
            log("User Present");
            // final userProvider = Provider.of<MyUser>(context,listen: false);
            // final data =  databaseMethods.getUserDetails(user.uid);
            // log(data.toString());
            // userProvider.upDateUser(userId: user.uid, email: user.email);
            // Future.delayed(Duration(seconds: 10));
            return SplashScreen();
          } else {
            log("User Log out");
            return SignIn();
          }
        });
  }
}
