import 'package:chat_app/modal/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // String firebaseuserUid;

  MyUser _userFromFirebaseUser({@required User firebaseUser}) {
    return firebaseUser != null ? MyUser(userId: firebaseUser.uid) : null;
  }

  Stream<MyUser> get authStateChanges {
    return _auth
        .authStateChanges()
        .map((user) => _userFromFirebaseUser(firebaseUser: user));
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    User firebaseUser;
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      firebaseUser = result.user;
      // firebaseuserUid = firebaseUser.uid;
      // return _userFromFirebaseUser(firebaseUser: firebaseUser);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print(e);
    }
    return firebaseUser != null ? firebaseUser : null;
  }
 
  Future <User> signUpWithEmailAndPassword(String email, String password) async {
    User firebaseUser;
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      firebaseUser = result.user;
      
      // return _userFromFirebaseUser(firebaseUser: firebaseUser);
    } catch (e) {
      print(e);
    }
     return firebaseUser != null ? firebaseUser : null;
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateUser(User user, String username) async {
    await user.updateProfile(displayName: username);
    _auth.currentUser.reload();
  }

  User getCurrentUser(){
    return _auth.currentUser;
  }
}
