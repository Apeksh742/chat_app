

import 'package:flutter/widgets.dart';

class MyUser extends ChangeNotifier {
  String userId;
  String email;
  String username;
  
  upDateUser(String userId,String email,String username){
    this.userId=userId;
    this.email=email;
    this.username=username;
    
  }
}