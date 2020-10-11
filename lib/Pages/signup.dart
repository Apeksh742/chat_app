import 'package:chat_app/Widget/widget.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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
                    signInAndSignUpUpTextFields(
                        context, "Username", false, Icon(Icons.person_outline)),
                    SizedBox(height: 20),
                    signInAndSignUpUpTextFields(
                        context, "Email", false, Icon(Icons.email_outlined)),
                    SizedBox(
                      height: 20,
                    ),
                    signInAndSignUpUpTextFields(context, "Password", true,
                        Icon(Icons.lock_open_outlined)),
                    SizedBox(
                      height: 40,
                    ),
                    MaterialButton(
                      onPressed: () {},
                      elevation: 4,
                      height: 50,
                      minWidth: MediaQuery.of(context).size.width * 0.7,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      color: Color(0xff9A88ED),
                      colorBrightness: Brightness.dark,
                      child: Text("Sign Up"),
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
                        Text(
                          " Sign In",
                          style: TextStyle(color: Color(0xff9A88ED), fontSize: 15),
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