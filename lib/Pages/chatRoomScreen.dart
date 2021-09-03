import 'dart:developer' as developerlog;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Pages/conversationScreen.dart';
import 'package:chat_app/Pages/editProfile.dart';
import 'package:chat_app/Pages/searchUser.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/modal/user.dart';
import 'package:chat_app/services/authMethods.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> with WidgetsBindingObserver {
  DatabaseMethods databaseMethods = DatabaseMethods();
  User currentUser;
  List<String> myusers = []; //List of all users which help while serching users
  @override
  void initState() {
    super.initState();
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser;
      currentUser.reload();
    });
    databaseMethods.changeOnlineStatus({
      "status": true,
    }, currentUser.uid);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      updateUserAndGetListOfAllUsers();
    });
    WidgetsBinding.instance.addObserver(this);
    print("initState called");

    print('Current user name init state : ${currentUser.displayName}');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      databaseMethods.changeOnlineStatus({
        "status": true,
      }, currentUser.uid);
      developerlog.log("Status Online");
    } else {
      databaseMethods.changeOnlineStatus({
        "status": false,
      }, currentUser.uid);
    }
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
    developerlog.log(await HelperFunctions.getUserNameSharedPreference());
    developerlog.log(await HelperFunctions.getUserEmailSharedPreference());
    final myuser = Provider.of<MyUser>(context, listen: false);
    myuser.upDateUser(
        currentUser.uid, currentUser.email, currentUser.displayName);
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
                accountName: FutureBuilder(
                  future: HelperFunctions.getUserNameSharedPreference(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data ?? "");
                    }
                    return LoadingIndicator(indicatorType: Indicator.ballPulse);
                  },
                ),
                accountEmail: FutureBuilder(
                  future: HelperFunctions.getUserEmailSharedPreference(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data ?? "");
                    }
                    return LoadingIndicator(indicatorType: Indicator.ballPulse);
                  },
                ),
                currentAccountPicture: FutureBuilder<QuerySnapshot>(
                    future: databaseMethods.getProfileData(currentUser.uid),
                    builder: (BuildContext ctx,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        Map<String, dynamic> data =
                            snapshot.data.docs.first.data();
                        if (data.containsKey("profileURL")) {
                          String profileURL =
                              snapshot.data.docs.first.get("profileURL");

                          return CachedNetworkImage(
                            imageUrl: profileURL,
                            imageBuilder: (context, imageProvider) => Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                                height: 100,
                                width: 100,
                                child: Center(
                                    child: LoadingIndicator(
                                  indicatorType: Indicator.circleStrokeSpin,
                                ))),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          );
                        }

                        return CircleAvatar(
                          backgroundColor: Colors.red,
                          child: FutureBuilder(
                            future:
                                HelperFunctions.getUserNameSharedPreference(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  (snapshot.data[0] ?? ""),
                                  style: TextStyle(fontSize: 40.0),
                                );
                              }
                              return Container();
                            },
                          ),
                        );
                      } else {
                        return CircleAvatar(
                          backgroundColor: Colors.red,
                          child: FutureBuilder(
                            future:
                                HelperFunctions.getUserNameSharedPreference(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  (snapshot.data[0] ?? ""),
                                  style: TextStyle(fontSize: 40.0),
                                );
                              }
                              return Container();
                            },
                          ),
                        );
                      }
                    })),
            // Consumer<MyUser>(builder: (context, myUser, child) {
            //   return UserAccountsDrawerHeader(
            //     accountName: Text(myUser.username ?? ""),
            //     accountEmail: Text(myUser.email ?? ""),
            //     currentAccountPicture: CircleAvatar(
            //       backgroundColor: Colors.red,
            //       child: Text(
            //         (myUser.username[0] ?? ""),
            //         style: TextStyle(fontSize: 40.0),
            //       ),
            //     ),
            //   );
            // }),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Edit Profile"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => EditProfile()));
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
                                Navigator.pop(context);
                                final myuser =
                                    Provider.of<MyUser>(context, listen: false);
                                databaseMethods.changeOnlineStatus({
                                  "status": false,
                                }, myuser.userId);
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
                .recentChatsStreams(auth.getCurrentUser().displayName),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              print(
                  "Stream Builder Recent Chat Users called : ${snapshot.connectionState}");
              if (snapshot.connectionState == ConnectionState.active) {
                List<QueryDocumentSnapshot> recentChatList = snapshot.data.docs;
                print("Recent Chat Query Document Snapshot: $recentChatList");
                print("user_username : ${auth.getCurrentUser().displayName}");
                String chatRoomId;
                return ListView.builder(
                    itemCount: recentChatList.length,
                    itemBuilder: (context, index) {
                      print(recentChatList[index].data());
                      // List queryData = recentChatList[index].get("users");
                      // String usernameOfRecentChats =
                      //     getUsernamesOfRecentConversations(queryData);
                      chatRoomId = recentChatList[index].get('chatRoomId');
                      print(chatRoomId);
                      return StreamBuilder(
                          stream: databaseMethods
                              .checkForFirstConversation(chatRoomId),
                          builder: (context, checkorFirstConversationsnapshot) {
                            if (checkorFirstConversationsnapshot.hasData) {
                              print(
                                  "check for first message: ${checkorFirstConversationsnapshot.data.docs.length}");
                              if (checkorFirstConversationsnapshot
                                      .data.docs.length !=
                                  0)
                                print(
                                    "data of first message: ${checkorFirstConversationsnapshot.data.docs[0].data()}");
                              if (checkorFirstConversationsnapshot
                                      .data.docs.length !=
                                  0) {
                                print(checkorFirstConversationsnapshot
                                    .data.docs[0]
                                    .get('users'));
                                print(getUsernamesOfRecentConversations(
                                    checkorFirstConversationsnapshot
                                        .data.docs[0]
                                        .get('users')));
                                String usernameOfRecentChats =
                                    getUsernamesOfRecentConversations(
                                        checkorFirstConversationsnapshot
                                            .data.docs[0]
                                            .get('users'));
                                return InkWell(
                                  onTap: () {
                                    print(usernameOfRecentChats);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ConversationScreen(
                                                  chatRoomId:
                                                      recentChatList[index]
                                                          .get('chatRoomId'),
                                                  receiverName:
                                                      usernameOfRecentChats,
                                                )));
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(children: [
                                      // CircleAvatar(//TODO:
                                      //   backgroundColor: Colors
                                      //       .primaries[Random().nextInt(15)],
                                      //   child: Icon(Icons.person),
                                      // ),
                                      FutureBuilder<QuerySnapshot>(
                                        future:
                                            databaseMethods.findUserbyUsername(
                                                usernameOfRecentChats),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (snapshot.hasData) {
                                            Map<String, dynamic> data =
                                                snapshot.data.docs.first.data();
                                            if (data
                                                .containsKey("profileURL")) {
                                              String profileURL = snapshot
                                                  .data.docs.first
                                                  .get("profileURL");

                                              return CachedNetworkImage(
                                                imageUrl: profileURL,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        CircleAvatar(
                                                  backgroundImage:
                                                      imageProvider,
                                                ),
                                                placeholder: (context, url) =>
                                                    CircleAvatar(
                                                        child: Center(
                                                            child:
                                                                CircularProgressIndicator())),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              );
                                            }
                                            return CircleAvatar(
                                                child: Text(
                                                    usernameOfRecentChats[0]
                                                        .toUpperCase()));
                                          }
                                          return CircleAvatar(
                                              child: Text(
                                                  usernameOfRecentChats[0]
                                                      .toUpperCase()));
                                        },
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                            child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "$usernameOfRecentChats" ?? "",
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Builder(
                                                builder: (BuildContext ctx) {
                                              String
                                                  chatRoomidToAvoidOverriding =
                                                  recentChatList[index]
                                                      .get('chatRoomId');
                                              print(
                                                  "ChatRoom ID: $chatRoomidToAvoidOverriding");
                                              var documentData =
                                                  checkorFirstConversationsnapshot
                                                      .data.docs[0];
                                              print(
                                                  "Current message : ${documentData.get('message')}");
                                              if (documentData.get("isPhoto") !=
                                                  true) {
                                                return Text(
                                                  documentData.get("message") ??
                                                      '',
                                                  maxLines: 1,
                                                );
                                              } else if (documentData
                                                      .get("isPhoto") ==
                                                  true) {
                                                return Row(children: [
                                                  Icon(
                                                    Icons.photo,
                                                    color: Colors.grey,
                                                  ),
                                                  Text(" Photo")
                                                ]);
                                              } else
                                                return Container();
                                            })
                                          ],
                                        )),
                                      )
                                    ]),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            } else {
                              return Container();
                            }
                          });
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
