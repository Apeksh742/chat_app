import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  Future uploadData(Map<String, dynamic> userInfo) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .add(userInfo)
        .catchError((e) {
      print(e.toString());
    });
  }

  // Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails(String uid) async{
  //   return await FirebaseFirestore.instance.collection("Users").doc(uid).get().catchError((e) {print(e.toString());});
  // }

  Future<QuerySnapshot> findUserByEmail(String email) async {
    try {
      return await FirebaseFirestore.instance
          .collection("Users")
          .where("Email", isEqualTo: email)
          .get()
          .catchError((e) {
        print(e.toString());
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<QuerySnapshot> findUser(String username) async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .where("Username", isEqualTo: username)
        .get()
        .catchError((e) {
      print(e.toString());
    });
  }

  Future createChatRoom(String chatRoomId, chatRoomMap) async {
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Future sendMessage(String chatroomId, Map messageMap) async {
    await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatroomId)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  Stream<QuerySnapshot> showMessages(String chatroomId) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatroomId)
        .collection("chats")
        .orderBy("created", descending: true)
        .snapshots();
  }

  showAllUsers() {
    FirebaseFirestore.instance.collection("Users").get().catchError((e) {
      print(e.toString());
    });
  }

  Stream<QuerySnapshot> recentChatsStreams(String username) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .where('users', arrayContains: "$username")
        .snapshots();
  }

  Stream checkForFirstConversation(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("created", descending: true)
        .limit(1)
        .snapshots();
  }

  Stream showRecentMessages(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("created", descending: true)
        .limit(1)
        .snapshots();
  }

  Future<QuerySnapshot> getAllUsers() {
    return FirebaseFirestore.instance.collection("Users").get();
  }

  Future changeOnlineStatus(Map<String, dynamic> status, String uid) async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("Users")
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();
    document.docs.forEach((element) {
      log(element.id);
      FirebaseFirestore.instance
          .collection("Users")
          .doc(element.id)
          .update(status);
    });
  }

  Future changeCurrentUserData(Map<String, dynamic> data, String uid) async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("Users")
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();
    document.docs.forEach((element) {
      log(element.id);
      FirebaseFirestore.instance
          .collection("Users")
          .doc(element.id)
          .update(data);
    });
  }

  

  Future updateProfilePicture(
      Map<String, dynamic> profileLink, String uid) async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("Users")
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();
    document.docs.forEach((element) {
      log(element.id);
      FirebaseFirestore.instance
          .collection("Users")
          .doc(element.id)
          .update(profileLink);
    });
  }

  Stream checkUserStatus(String receiverName) {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("Username", isEqualTo: receiverName)
        .limit(1)
        .get()
        .asStream();
  }

  Future findUserbyUsername(String receiverName) {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("Username", isEqualTo: receiverName)
        .limit(1)
        .get();
  }

  Future updateProfileData(Map<String, dynamic> data, String uid) async {
    QuerySnapshot document = await FirebaseFirestore.instance
        .collection("Users")
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();
    document.docs.forEach((element) {
      log(element.id);
      FirebaseFirestore.instance
          .collection("Users")
          .doc(element.id)
          .update(data);
    });
  }

  Stream getProfile(String uid) {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get()
        .asStream();
  }

  Future getProfileData(String uid) {
    return FirebaseFirestore.instance
        .collection("Users")
        .where("uid", isEqualTo: uid)
        .limit(1)
        .get();
  }
}
