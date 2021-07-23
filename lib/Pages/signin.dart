import 'dart:developer';

import 'package:chat_app/Pages/signup.dart';
import 'package:chat_app/Widget/widget.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();
  final formKey = GlobalKey<FormState>();

  Future<String> getUserName(String email) async {
    try {
      return await databaseMethods.findUserByEmail(email).then((value) {
        if (value.docs.length != null) {
          return value.docs[0].get("Username");
        } else {
          return null;
        }
      });
    } catch (e) {
      log(e.toString());
      return null;
    }
    // HelperFunctions.saveUserNameSharedPreference(username)
  }

  signIn() async {
    if (formKey.currentState.validate()) {
      setState(() {
        isLoading = true;
      });
      await HelperFunctions.saveUserEmailSharedPreference(emailController.text);
      String username = await getUserName(emailController.text);

      log(await HelperFunctions.getUserEmailSharedPreference());
      log(await HelperFunctions.getUserNameSharedPreference());

      if (username != null) {
        await HelperFunctions.saveUserNameSharedPreference(username);
        final auth = Provider.of<AuthMethods>(context, listen: false);
        auth
            .signInWithEmailAndPassword(
                emailController.text, passwordController.text)
            .then((value) {
          if (value == null) {
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
                    content: Text(
                        "Your email or password was incorrect. Please try again."),
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
          } else {
          }
        }
        );
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Error",
                  style: TextStyle(color: Colors.red),
                ),
                content: Text("Your email or password was incorrect. Please try again."),
                actions: <Widget>[
                  FlatButton(
                      color: Color(0xff4081EC),
                      colorBrightness: Brightness.dark,
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: Text("Close"))
                ],
              );
            });
      }
      setState(() {
        isLoading = true;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBarMain(context),
        backgroundColor: Colors.white,
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
                          "Sign In",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w400),
                        )),
                    SizedBox(height: 25),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
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
                          SizedBox(height: 20),
                          Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                    color: Color(0xff9A88ED), fontSize: 15),
                              )),
                          SizedBox(
                            height: 30,
                          ),
                          MaterialButton(
                              onPressed: () async {
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                                await signIn();
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
                                          new AlwaysStoppedAnimation<Color>(
                                              Colors.white))
                                  : Text("Sign In")),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Text(
                        "Don't have an accout? Register Now ",
                        style:
                            TextStyle(color: Color(0xff9A88ED), fontSize: 15),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 2,
                          width: 35,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(width: 4),
                        Text("OR", style: TextStyle(fontSize: 15)),
                        SizedBox(width: 4),
                        Container(
                          height: 2,
                          width: 35,
                          color: Colors.grey.shade400,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage("assets/logos/Facebook.png"),
                        ),
                        SizedBox(width: 20),
                        CircleAvatar(
                          radius: 30,
                          backgroundImage:
                              AssetImage("assets/logos/Google.jpg"),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        )));
  }
}
