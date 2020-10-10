import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget appBarMain(BuildContext context) {
  return AppBar(
      title: Text(
    "Chat App",
    style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 25),
  ));
}
