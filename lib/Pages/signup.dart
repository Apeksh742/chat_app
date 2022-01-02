import 'dart:developer';

import 'package:chat_app/Pages/chatRoomScreen.dart';
import 'package:chat_app/Pages/registerProfile.dart';
import 'package:chat_app/Pages/signin.dart';
import 'package:chat_app/Widget/widget.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/modal/user.dart';
import 'package:chat_app/modal/utilities.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController referController = TextEditingController();
  DatabaseMethods database = DatabaseMethods();
  // String temp = "Link";

  @override
  void initState() {
    super.initState();
    // checkReferalCode();
  }

  // checkReferalCode() {
  //   final PendingDynamicLinkData initialLink =
  //       Provider.of<Utilities>(context, listen: false).referralLink;
  //   if (initialLink != null) {
  //     final Uri deepLink = initialLink.link;
  //     final queryParams = deepLink.queryParameters;
  //     if (queryParams.length > 0) {
  //       String referCode = queryParams['code'];
  //       setState(() { 
  //         referController.text = referCode;
  //       });
  //     }
  //   }
  // }

  validateUserInfo() async {
    if (formKey.currentState.validate()) {
      final String username = usernameController.text;

      final auth = Provider.of<AuthMethods>(context, listen: false);
      try {
        setState(() {
          if (mounted) isLoading = true;
        });
        await auth
            .signUpWithEmailAndPassword(
                emailController.text, passwordController.text)
            .then((user) async {
          if (user != null) {
            log("User created Succesfully");
            final userProvider = Provider.of<MyUser>(context, listen: false);
            userProvider.upDateUser(
                userId: user.uid,
                username: usernameController.text,
                email: emailController.text);
            user.updateDisplayName(username);
            HelperFunctions.saveUserEmailSharedPreference(emailController.text);
            HelperFunctions.saveUserNameSharedPreference(
                usernameController.text);
            // setState(() {
            //   if (mounted) isLoading = false;
            // });
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => RegisterProfile()));
            Map<String, dynamic> userInfo = {
              "Username": usernameController.text,
              "Email": user.email,
              "uid": user.uid,
              "status": true,
            };
            // print("Firebase Username updated : ${user.displayName}");
            database.uploadData(userInfo);
          }
          if (user == null) {
            setState(() {
              isLoading = false;
            });
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(
                      "Error",
                      style: TextStyle(color: Colors.red),
                    ),
                    content: Text("Email lready in use"),
                    actions: <Widget>[
                      FlatButton(
                          color: Color(0xff4081EC),
                          colorBrightness: Brightness.dark,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Close"))
                    ],
                  );
                });
          }
        });
      } on Exception catch (e) {
        setState(() {
          if (mounted) isLoading = false;
        });
        print(e.toString());
      }
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    referController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.w400),
                      )),
                  SizedBox(height: 25),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        SignInAndSignUpTextFormFields(
                            controller: usernameController,
                            hinttext: "Username",
                            obscurity: false,
                            icon: Icon(Icons.person_outline)),
                        SizedBox(height: 20),
                        SignInAndSignUpTextFormFields(
                            controller: emailController,
                            hinttext: "Email",
                            obscurity: false,
                            icon: Icon(Icons.email_outlined)),
                        SizedBox(
                          height: 20,
                        ),
                        SignInAndSignUpTextFormFields(
                            controller: passwordController,
                            hinttext: "Password",
                            obscurity: true,
                            icon: Icon(Icons.lock_open_outlined)),
                        SizedBox(
                          height: 20,
                        ),
                        Consumer<Utilities>(builder: (context, util, child) {
                          if (referController.text !=
                              util.referCode && util.referralLink!=null) {   
                            referController.text =
                                util.referCode;
                          }
                          return TextField(
                            controller: referController,
                            onChanged: (value) {
                              // Refer code logic
                            },
                            decoration: InputDecoration(
                                labelText: "Refer code",
                                hintText: "Refer Code",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                          );
                        }),
                        // TextField(
                        //   controller: referController,
                        //   onChanged: (value) {
                        //     // Refer code logic
                        //   },
                        //   decoration: InputDecoration(
                        //       labelText: "Refer code",
                        //       hintText: "Refer Code",
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(20))),
                        // ),
                        SizedBox(
                          height: 20,
                        ),
                        // Consumer<Utilities>(builder: (context, util, child) {
                        //   return Text(util.referralCode.toString(),
                        //       style: TextStyle(
                        //           color: Color(0xff9A88ED), fontSize: 15));
                        // })
                        // SizedBox(
                        //     width: double.infinity * 0.8,
                        //     child: Center(child: Text(temp)))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  MaterialButton(
                    onPressed: () {
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      validateUserInfo();
                    },
                    elevation: 4,
                    height: 50,
                    minWidth: MediaQuery.of(context).size.width * 0.7,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    color: Color(0xff9A88ED),
                    colorBrightness: Brightness.dark,
                    child: isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                new AlwaysStoppedAnimation<Color>(Colors.white))
                        : Text("Sign Up"),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Have an Account?",
                        style: TextStyle(fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignIn()));
                        },
                        child: Text(
                          " Sign In",
                          style:
                              TextStyle(color: Color(0xff9A88ED), fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
