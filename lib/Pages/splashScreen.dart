import 'dart:developer' as developerlog;
import 'dart:developer';

import 'package:chat_app/Pages/chatRoomScreen.dart';
import 'package:chat_app/Pages/signin.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/modal/user.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DatabaseMethods databaseMethods = DatabaseMethods();
  User currentUser;
  @override
  void initState() {
    currentUser = FirebaseAuth.instance.currentUser;
    getCurrentUser();
    super.initState();
  }

  Future getCurrentUser() async {
    // developerlog.log(await HelperFunctions.getUserNameSharedPreference());
    // developerlog.log(await HelperFunctions.getUserEmailSharedPreference());

    final myuser = Provider.of<MyUser>(context, listen: false);
    currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser!= null){
    myuser.upDateUser(
        userId: currentUser.uid,
        email: currentUser.email,
        username: currentUser.displayName);
    final QuerySnapshot data =
        await databaseMethods.findUserByEmail(currentUser.email);
    developerlog.log(currentUser.uid.toString());
    
    developerlog.log(data.docs.first.get("profileURL").toString());
    myuser.upDateUser(
        userId: currentUser.uid,
        email: currentUser.email,
        username: currentUser.displayName,
        profileURL: data.docs.first.get("profileURL") ?? null);
    print('update User successfully');
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> ChatRoom()), (route) => false);
    }
    else{
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (ctx) => SignIn()), (route) => false);
    }
    // databaseMethods
    //     .getAllUsers()
    //     .then((value) => value.docs.forEach((element) {
    //           String getName = element.get('Username');
    //           myusers.add(getName);
    //         }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset("assets/logos/myChatLogo.png")),
    );
  }
}
