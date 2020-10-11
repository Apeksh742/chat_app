import 'package:chat_app/Widget/widget.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                          style:
                              TextStyle(color: Color(0xff9A88ED), fontSize: 15),
                        )),
                    SizedBox(
                      height: 30,
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
                      child: Text("Sign In"),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Text(
                      "Don't have an accout?",
                      style: TextStyle(color: Color(0xff9A88ED), fontSize: 15),
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
