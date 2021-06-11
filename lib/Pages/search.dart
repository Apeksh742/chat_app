// import 'package:chat_app/Pages/conversationScreen.dart';
// // import 'package:chat_app/modal/user.dart';
// import 'package:chat_app/services/authMethods.dart';

// import 'package:chat_app/services/databasemethod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';

// class SearchUser extends StatefulWidget {
//   final myUser;
//   SearchUser(this.myUser);
//   @override
//   _SearchUserState createState() => _SearchUserState();
// }

// class _SearchUserState extends State<SearchUser> {
//   DatabaseMethods databaseMethods = DatabaseMethods();
//   TextEditingController searchController = TextEditingController();
//   QuerySnapshot querySnapshot;

//   initiateSearch() {
//     databaseMethods.findUser(searchController.text).then((value) {
//       setState(() {
//         querySnapshot = value;
//       });
//     });
//   }

//   Widget searchTile(BuildContext context, {String username, String email}) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             children: [
//               Text(
//                 username,
//                 style: TextStyle(fontSize: 16),
//               ),
//               SizedBox(height: 8),
//               Text(email, style: TextStyle(fontSize: 16)),
//             ],
//           ),
//           GestureDetector(
//             onTap: () {
//               print("createChatRoomAndStartConversation called");
//               createChatRoomAndStartConversation(username, context);
//             },
//             child: Container(
//               padding: EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(30), color: Colors.red),
//               child: Text(
//                 "Message",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget showSearchResult(BuildContext context) {
//     return querySnapshot != null
//         ? ListView.builder(
//             itemCount: querySnapshot.docs.length,
//             shrinkWrap: true,
//             scrollDirection: Axis.vertical,
//             itemBuilder: (context, index) {
//               return searchTile(
//                 context,
//                 username: querySnapshot.docs[index].data()["Username"],
//                 email: querySnapshot.docs[index].data()["Email"],
//               );
//             })
//         : Container();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     searchController.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: appBarMain(context),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border(bottom: BorderSide(color: Colors.black26)),
//                 ),
//                 child: Padding(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
//                   child: Row(
//                     children: [
//                       IconButton(
//                           icon: Icon(Icons.arrow_back),
//                           onPressed: () {
//                             Navigator.pop(context);
//                           }),
//                       Expanded(
//                         child: Container(
//                             height: 30,
//                             child: TextField(
//                               autofocus: true,
//                               cursorColor: Colors.red,
//                               controller: searchController,
//                               decoration: InputDecoration(
//                                   hintText: "Search",
//                                   focusedBorder: UnderlineInputBorder(
//                                       borderSide:
//                                           BorderSide(color: Colors.black))),
//                             )),
//                       ),
//                       IconButton(
//                           icon: Icon(Icons.search),
//                           onPressed: () {
//                             SystemChannels.textInput
//                                 .invokeMethod('TextInput.hide');
//                             initiateSearch();
//                           }),
//                     ],
//                   ),
//                 ),
//               ),
//               showSearchResult(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// createChatRoomAndStartConversation(
//     String receiverUsername, BuildContext context) {
//   final auth = Provider.of<AuthMethods>(context, listen: false);
//   final user = auth.getCurrentUser();
//   if (receiverUsername != user.displayName) {
//     print("ChatroomFunctionCalled");

//     getChatRoomId(String a, String b) {
//       if (a.length > b.length) {
//         return "${a}_$b";
//       } else if (a.length == b.length) {
//         for (int i = 0; i < a.length; i++) {   
//             if (a.substring(0).codeUnitAt(i)>
//                 b.substring(0).codeUnitAt(i)) {
//               return "${a}_$b";
//             } else if (a.substring(0).codeUnitAt(i)<
//                 b.substring(0).codeUnitAt(i)) {
//               return "${b}_$a";     
//           }
//         }
//       } else {
//         return "${b}_$a";
//       }
//     }

//     String chatRoomId = getChatRoomId(receiverUsername, user.displayName);
//     List<String> users = [receiverUsername, user.displayName];
//     Map<String, dynamic> chatRoomMap = {
//       "users": users,
//       "chatRoomId": chatRoomId
//     };
//     print(chatRoomId);
//     print(chatRoomMap);
//     DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);

//     Navigator.push(context, MaterialPageRoute(builder: (context) {
//       return ConversationScreen(receiverName: receiverUsername, chatRoomId: chatRoomId,);
//     }));
//   } else {
//     print("You can't message yourself");
//   }
// }
