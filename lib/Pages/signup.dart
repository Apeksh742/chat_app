import 'package:chat_app/Pages/signin.dart';
import 'package:chat_app/Widget/widget.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:chat_app/services/databasemethod.dart';
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
  DatabaseMethods database = DatabaseMethods();

  validateUserInfo() async {
    if (formKey.currentState.validate()) {
      // HelperFunctions.saveUserEmailSharedPreference(emailController.text);
      // HelperFunctions.saveUserNameSharedPreference(usernameController.text);
      final auth = Provider.of<AuthMethods>(context, listen: false);
      try {
        auth
            .signUpWithEmailAndPassword(emailController.text,
                passwordController.text)
            .then((user) {
          // user.updateProfile(displayName: usernameCfluontroller.text);
          user.updateDisplayName(usernameController.text);
          user.reload();
          
          Map<String, String> userInfo = {
            "Username": usernameController.text,
            "Email": user.email,
            "uid": user.uid
          };
          print("Firebase Username updated : ${user.displayName}");
          database.uploadData(userInfo);
        });
      } on Exception catch (e) {
        print(e.toString());
      }
      setState(() {
        if (mounted) isLoading = true;
      });
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
                           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
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
