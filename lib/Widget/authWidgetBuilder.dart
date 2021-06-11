import 'package:chat_app/modal/user.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AuthWidgetBuilder extends StatelessWidget {
  final Widget Function(BuildContext, AsyncSnapshot<MyUser>) builder;
  AuthWidgetBuilder({Key key, @required this.builder}) : super(key: key);

  Widget build(BuildContext context) {
    print("AuthWidgetBuilderStreamBuilder called");
    AuthMethods auth = Provider.of<AuthMethods>(context, listen: false);
    return StreamBuilder<MyUser>(
        stream: auth.authStateChanges,
        builder: (context, snapshot) {
          print("AuthWidgetBuilder Stream Builder : " + snapshot.connectionState.toString());
          final user = snapshot.data;
          if (user != null) {
            return Provider<MyUser>.value(              // You can use Multi Provider here if Firestore services are required
              value: user,
              child: builder(context, snapshot),
            );
          }

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
