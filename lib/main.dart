import 'package:chat_app/Widget/authWidgetBuilder.dart';

import 'package:chat_app/services/authMethods.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'Widget/authWidget.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(providers: [
      Provider<AuthMethods>(create: (context) => AuthMethods()),
    ],
   child: AuthWidgetBuilder(builder: (context,userSnapshot) => MaterialApp(
     debugShowCheckedModeBanner: false,
     home: AuthWidget(userSnapshot: userSnapshot,)
   )),
  );
    
  }
}
