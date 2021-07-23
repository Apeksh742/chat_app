import 'dart:developer';

import 'package:chat_app/Pages/chatRoomScreen.dart';
import 'package:chat_app/Pages/signin.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Authenticate extends StatelessWidget {
  const Authenticate({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.active) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = snapshot.data;

          if (user != null) {
            log("User Present");
            Future.delayed(Duration(seconds: 1));
            return ChatRoom();
          } else {
            return SignIn();
          }
        });
  }
}
