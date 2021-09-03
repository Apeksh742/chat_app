// import 'dart:developer' as developerlog;

// import 'package:chat_app/helper/helperfunctions.dart';
// import 'package:chat_app/modal/user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';


// class SplashScreen extends StatefulWidget {
//   const SplashScreen({ Key key }) : super(key: key);

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   User currentUser;
//   @override
//   void initState() { 
//     super.initState();
//     setState(() {
//       currentUser = FirebaseAuth.instance.currentUser;
//       currentUser.reload();
//     });
    
//   }
//   Future getCurrentUser()async{
//       developerlog.log(await HelperFunctions.getUserNameSharedPreference());
//       developerlog.log(await HelperFunctions.getUserEmailSharedPreference());
//       final myuser = Provider.of<MyUser>(context, listen: false);
//       myuser.upDateUser(
//           currentUser.uid, currentUser.email, currentUser.displayName);
//       print('update User successfully');

//       // databaseMethods
//       //     .getAllUsers()
//       //     .then((value) => value.docs.forEach((element) {
//       //           String getName = element.get('Username');
//       //           myusers.add(getName);
//       //         }));
    
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
      
//     );
//   }
// }