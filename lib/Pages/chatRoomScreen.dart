import 'dart:math';
import 'package:chat_app/Pages/conversationScreen.dart';
import 'package:chat_app/Pages/searchUser.dart';
import 'package:chat_app/modal/user.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  DatabaseMethods databaseMethods = DatabaseMethods();
  final currentUser = FirebaseAuth.instance.currentUser;
  List<String> myusers = []; //List of all users which help while serching users
  @override
  void initState() {
    super.initState();
    print("initState called");
    print('Current user name init state : ${currentUser.displayName}');
    updateUserAndGetListOfAllUsers();
  }

  getUsernamesOfRecentConversations(List a) {
    int n;
    for (int i = 0; i < a.length; i++) {
      if (a[i] == currentUser.displayName) {
        n = i;
        break;
      }
    }

    for (int i = 0; i < a.length; i++) {
      if (i == n) {
        continue;
      } else {
        return a[i];
      }
    }
  }

  void updateUserAndGetListOfAllUsers() async {
    final user = Provider.of<MyUser>(context, listen: false);
    user.username = currentUser.displayName;
    user.email = currentUser.email;
    print('update User successfully');

    databaseMethods.getAllUsers().then((value) => value.docs.forEach((element) {
          String getName = element.get('Username');
          myusers.add(getName);
        }));
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthMethods>(context, listen: false);
    print(auth.getCurrentUser().displayName);
    print("Builder called");
    return Scaffold(
      appBar: AppBar(
        title: Text("Messages",
            style:
                GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 25)),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(currentUser.displayName ?? ""),
              accountEmail: Text(currentUser.email ?? ""),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.red,
                child: Text(
                  (currentUser.displayName ?? "").toUpperCase()[0],
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.contacts),
              title: Text("Contact Us"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Log Out"),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Log out of app?"),
                        content: Text(
                            "Are you sure you want to log out of the app!"),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel")),
                          FlatButton(
                              color: Color(0xff4081EC),
                              colorBrightness: Brightness.dark,
                              onPressed: () {
                                final auth = Provider.of<AuthMethods>(context,
                                    listen: false);
                                auth.signOut();
                              },
                              child: Text("Log Out"))
                        ],
                      );
                    });
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String selectedUserFromSearch = await showSearch(
              context: context,
              delegate: UserSearch(
                  users: myusers, currentUser: currentUser.displayName));
          if (selectedUserFromSearch != null) {
            print("result from search : $selectedUserFromSearch");
            createChatRoomAndStartConversation(selectedUserFromSearch, context);
          }
        },
        child: Icon(Icons.search),
      ),
      body: SafeArea(
          child: Container(
        padding: EdgeInsets.all(8),
        child: StreamBuilder(
            stream: databaseMethods
                .recentChatsStreams(auth.getCurrentUser().displayName), //TODO: Display users if subcollection chats doesn't exist also which gives error
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              print(
                  "Stream Builder Recent Chat Users called : ${snapshot.connectionState}");
              if (snapshot.connectionState == ConnectionState.active ) {
                List<QueryDocumentSnapshot> recentChatList = snapshot.data.docs;
                print("Recent Chat Query Document Snapshot: $recentChatList");
                print("user_username : ${auth.getCurrentUser().displayName}");
                String chatRoomId;
                // List<QueryDocumentSnapshot> chatListWithActiveConversation=[];

                // for(int i=0;i<recentChatList.length;i++){
                //    String chatRoomid = recentChatList[i].get('chatRoomId');
                //    recentChatList[i].
                // }


                // print(data.runtimeType);
                // recentChatList.
                // if()
                return ListView.builder(
                    itemCount: recentChatList.length,
                    itemBuilder: (context, index) {
                      print(recentChatList[index].data());
                      List queryData = recentChatList[index].get("users");
                      String usernameOfRecentChats =
                          getUsernamesOfRecentConversations(queryData);
                      chatRoomId = recentChatList[index].get('chatRoomId');
                      print(chatRoomId);
                      
                      // bool resultForActiveConversations=false;
                      // resultForActiveConversations = checkForFirstConversation(chatRoomId);
                      // print('Output of First Conversation function: ${checkForFirstConversation(chatRoomId)}');

                          
                                  // return FutureBuilder<Object>(
                                  //   future: checkForFirstConversation(chatRoomId),
                                  //   initialData: null,
                                  //   builder: (context, futuresnapshot) {
                                  //     if(futuresnapshot.hasData){
                                  //       print("Future Snapshot data: ${futuresnapshot.data}");
                                          return InkWell(             //TODO : check if user has chatted
                                onTap: () {
                                      print(usernameOfRecentChats);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ConversationScreen(
                                                    chatRoomId: recentChatList[index]
                                                        .get('chatRoomId'),
                                                    receiverName: usernameOfRecentChats,
                                                  )));
                                },
                                child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              Colors.primaries[Random().nextInt(15)],
                                          child: Icon(Icons.person),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                              child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "$usernameOfRecentChats" ?? "",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                              StreamBuilder(
                                                  stream: databaseMethods
                                                      .showRecentMessages(chatRoomId),
                                                  builder: (context, newSnapshot) {
                                                    print("ChatRoom ID: $chatRoomId");
                                                    print(
                                                        "Stream Builder Recent Chats called : ${newSnapshot.connectionState}");
                                                    if (newSnapshot.connectionState == ConnectionState.active ) {
                                                        
                                                      QuerySnapshot documentData =
                                                          newSnapshot.data;
                                                      print(documentData.runtimeType);
                                                      print(
                                                          "Current message : ${documentData.docs.first.get('message')}");

                                                    //  if (documentData.docs.first != null) {
                                                       
                                                      if (documentData.docs.first
                                                              .get("isPhoto") !=
                                                          true) {
                                                        return Text(
                                                          documentData.docs.first
                                                                  .get("message") ??
                                                              '',
                                                          maxLines: 1,
                                                        );
                                                      } else if (documentData.docs.first
                                                              .get("isPhoto") ==
                                                          true) {
                                                        return Row(children: [
                                                          Icon(
                                                            Icons.photo,
                                                            color: Colors.grey,
                                                          ),
                                                          Text(" Photo")
                                                        ]);
                                                      }
                                                    //  }
                                                    }
                                                    {
                                                      return Container(
                                                          child: Center(
                                                        child: CircularProgressIndicator(),
                                                      ));
                                                    }
                                                  })
                                            ],
                                          )),
                                        )
                                      ]),
                                ),
                              );
                                    //  }
                                    //  else{
                                    //    print("Future Snapshot null");
                                    //    return Container();
                                    //  }
                                    // }
                                  // );
                    });
              } else {
                return Container(
                    child: Center(
                  child: CircularProgressIndicator(),
                ));
              }
            }),
      )),
    );
  }
}

Future<bool> checkForFirstConversation(String chatRoomId) async {
    FirebaseFirestore.instance.collection("ChatRoom").doc(chatRoomId).collection('chats').limit(1).get().
      then((value) {
        if(value.docs.isNotEmpty) {
          print("Length is greater than 0");
          print(value.docs.first);
          return true;}
        else{
          print("Length < 0");
          // print(value.docs);
          return false;
        }
      });
      print("Not returned value");
      // return null;
      return false;
  }

createChatRoomAndStartConversation(
    String receiverUsername, BuildContext context) {
  final auth = Provider.of<AuthMethods>(context, listen: false);
  final user = auth.getCurrentUser();
  if (receiverUsername != user.displayName) {
    print("ChatroomFunctionCalled");

    getChatRoomId(String a, String b) {
      if (a.length > b.length) {
        return "${a}_$b";
      } else if (a.length == b.length) {
        for (int i = 0; i < a.length; i++) {
          if (a.substring(0).codeUnitAt(i) > b.substring(0).codeUnitAt(i)) {
            return "${a}_$b";
          } else if (a.substring(0).codeUnitAt(i) <
              b.substring(0).codeUnitAt(i)) {
            return "${b}_$a";
          }
        }
      } else {
        return "${b}_$a";
      }
    }

    String chatRoomId = getChatRoomId(receiverUsername, user.displayName);
    List<String> users = [receiverUsername, user.displayName];
    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatRoomId": chatRoomId
    };
    print(chatRoomId);
    print(chatRoomMap);
    DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ConversationScreen(
        receiverName: receiverUsername,
        chatRoomId: chatRoomId,
      );
    }));
  } else {
    print("You can't message yourself");
  }
}
