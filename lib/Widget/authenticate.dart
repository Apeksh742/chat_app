import 'dart:developer';

import 'package:chat_app/Pages/chatRoomScreen.dart';
import 'package:chat_app/Pages/signin.dart';
import 'package:chat_app/Pages/splashScreen.dart';
import 'package:chat_app/modal/user.dart';
import 'package:chat_app/modal/utilities.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Authenticate extends StatelessWidget {
  Authenticate({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          Provider.of<Utilities>(context, listen: false).subsribeSream();
          if (snapshot.connectionState != ConnectionState.active) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final User user = snapshot.data;

          if (user != null)  {
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
