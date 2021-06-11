import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods{
  
  Future uploadData(Map<String,String> userInfo)async {
    await FirebaseFirestore.instance.collection("Users").add(userInfo)
    .catchError((e){
      print(e.toString());
    });
  }

  Future<QuerySnapshot> findUserByEmail(String email) async {
   return await FirebaseFirestore.instance.collection("Users").where("Email", isEqualTo: email).get()
    .catchError((e){
      print(e.toString());
    });
  }

  Future<QuerySnapshot> findUser(String username) async {
   return await FirebaseFirestore.instance.collection("Users").where("Username", isEqualTo: username).get()
    .catchError((e){
      print(e.toString());
    });
  }

  Future createChatRoom(String chatRoomId, chatRoomMap) async {
    await FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).set(chatRoomMap)
     .catchError((e){
      print(e.toString());
    });
    
  }

  Future sendMessage(String chatroomId, Map messageMap) async {
    await FirebaseFirestore.instance.collection("ChatRoom").doc(chatroomId).collection("chats").add(messageMap);
  }

  Stream<QuerySnapshot> showMessages(String chatroomId) {
    return FirebaseFirestore.instance.collection("ChatRoom").doc(chatroomId).collection("chats").orderBy("created",descending: false).snapshots();
  }

  showAllUsers(){
    FirebaseFirestore.instance.collection("Users").get();
  }

  Stream<QuerySnapshot>  recentChatsStreams(String username)  {
    return FirebaseFirestore.instance.collection("ChatRoom").where('users', arrayContains: "$username").snapshots();
    // Query<Map<String, dynamic>> x =   FirebaseFirestore.instance.collection("ChatRoom").where('users', arrayContains: "$username");
    // x.get().then((value) {
    //   value.docs
    // });
  }

  

  Stream showRecentMessages(String chatRoomId){
    // Stream empty;
    // final data = FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).collection("chats").snapshots();
    // if(data!=null)
    return FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).collection("chats").orderBy("created", descending: true).limit(1).snapshots();
  //   else{
  //     return empty;
  //  }
  }

  Future<int> checkUserHasAnyCoversation(String chatRoomId){
    return FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).collection('chats').snapshots().length;
  }

  Future<QuerySnapshot> getAllUsers(){
    return FirebaseFirestore.instance.collection("Users").get();
  }

}
