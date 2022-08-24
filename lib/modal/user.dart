import 'package:flutter/widgets.dart';

class MyUser extends ChangeNotifier {
  String userId;
  String email;
  String username;
  String dob;
  String profileURL;
  String fcmToken;

  upDateUser(
      {String userId,
      String email,
      String username,
      String profileURL,
      String fcmToken}) {
    this.userId = userId;
    this.email = email;
    this.username = username;
    this.profileURL = profileURL;
    this.fcmToken = fcmToken;
  }

  updateProfile({String profileURL}) {
    this.profileURL = profileURL;
  }

  updateDOB(String dob) {
    this.dob = dob;
    notifyListeners();
  }
}
