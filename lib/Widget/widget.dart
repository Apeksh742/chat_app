import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
      title: Text(
    "Chat App",
    style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 25),
  ));
}

TextField signInAndSignUpUpTextFields(BuildContext context, String hintText, bool obscurity, Icon icon) {
  return TextField(
      obscureText: obscurity,
      cursorColor: Color(0xff9A88ED),
      decoration: InputDecoration(
        prefixIcon: icon,
        enabledBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        hintText: hintText,
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      ),
      );
}
