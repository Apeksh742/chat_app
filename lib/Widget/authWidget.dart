import 'dart:developer';

import 'package:chat_app/Pages/chatRoomScreen.dart';
import 'package:chat_app/Pages/signin.dart';
import 'package:chat_app/modal/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWidget extends StatelessWidget {

  AuthWidget({key: Key, this.userSnapshot});
  final AsyncSnapshot<User> userSnapshot;

  @override
  Widget build(BuildContext context) {
    if (userSnapshot.connectionState == ConnectionState.active){
      if(userSnapshot.hasData) {
        log("userSnapshot Present");
      }
      else{
        log("userSnapshot absent");
      }
      return userSnapshot.hasData ? ChatRoom() : SignIn();
    }
    return Scaffold(
      body: Center(child: CircularProgressIndicator(),)
    );
  }
}