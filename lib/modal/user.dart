import 'package:flutter/widgets.dart';

class MyUser extends ChangeNotifier {
  String userId;
  String email;
  String username;
  String dob;

  upDateUser(String userId, String email, String username) {
    this.userId = userId;
    this.email = email;
    this.username = username;
    notifyListeners();
  }

  updateDOB(String dob) {
    this.dob = dob;
    notifyListeners();
  }
}
