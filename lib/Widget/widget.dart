import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
      title: Text(
    "Chat App",
    style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 25),
  ));
}




class SignInAndSignUpTextFormFields extends StatefulWidget {
  final hinttext;
  final obscurity;
  final icon;
  final controller;
  @override
  _SignInAndSignUpTextFormFieldsState createState() => _SignInAndSignUpTextFormFieldsState();

  SignInAndSignUpTextFormFields({this.hinttext, this.obscurity, this.icon, this.controller});
}

class _SignInAndSignUpTextFormFieldsState extends State<SignInAndSignUpTextFormFields> {

  String myValidator(String typeOfFormField, String value){
    if (typeOfFormField == "Email"){
      return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(value)? null : "Please provide a valid Email Id";
    }
    else if (typeOfFormField == "Password"){
      return value.length > 7 && RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
      .hasMatch(value) ? null : "Password must be 8 characters including 1 uppercase letter, 1 special character, alphanumeric characters";
    }
    else if(typeOfFormField == "Username"){
      return value.length < 4 ? "Too Short!":null;
    }
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
   return TextFormField(
      validator: (value){
        return myValidator(widget.hinttext, value);
      },
      obscureText: widget.obscurity,
      cursorColor: Color(0xff9A88ED),
      decoration: InputDecoration(
        prefixIcon: widget.icon,
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        hintText: widget.hinttext,
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      ),
      );
  }
}
