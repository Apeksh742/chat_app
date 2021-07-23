import 'dart:developer';

import 'package:chat_app/modal/user.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWidgetBuilder extends StatelessWidget {
  final Widget Function(BuildContext, AsyncSnapshot<User>) builder;
  AuthWidgetBuilder({Key key, @required this.builder}) : super(key: key);

  Widget build(BuildContext context) {
    print("AuthWidgetBuilderStreamBuilder called");
    AuthMethods auth = Provider.of<AuthMethods>(context, listen: false);
    return StreamBuilder<User>(
        stream: auth.authStateChanges,
        builder: (context, snapshot) {
          print("AuthWidgetBuilder Stream Builder : " +
              snapshot.connectionState.toString());
          final user = snapshot.data;
          if (user != null) {
            log("AuthWidgetStream : User Present");
            return builder(context, snapshot);
          }
           log("AuthWidgetStream : User Absent");
          // else {
          //   if (showSignIn)
          //     return SignIn(toggleView);
          //   else {
          //     return SignUp(toggleView);
          //   }
          // }
          return builder(context, snapshot);
        });
  }
}
