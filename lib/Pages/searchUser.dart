import 'package:chat_app/services/authMethods.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'conversationScreen.dart';


class UserSearch extends SearchDelegate<String> {
  final List<String> users;
  final String currentUser;
  UserSearch({@required this.users,@required this.currentUser});


  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    users.remove(currentUser);
    users.join(', ');
    List<String> suggestionList = query.isEmpty
        ? users.getRange(0, 2).toList()
        : users.where((element) => element.startsWith(query)).toList();
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(
            onTap: () {
              createChatRoomAndStartConversation(suggestionList[index], context);
            },
            leading: Icon(Icons.person),
            title: RichText(
              text: TextSpan(
                  text: suggestionList[index].substring(0, query.length),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: suggestionList[index].substring(query.length),
                        style: TextStyle(color: Colors.grey))
                  ]),
            )));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    users.remove(currentUser);
    users.join(', ');
    List<String> suggestionList = query.isEmpty
        ? users.getRange(0, 2).toList()
        : users.where((element) => element.startsWith(query)).toList();
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(
            onTap: () {
              showResults(context);
              createChatRoomAndStartConversation(suggestionList[index], context);
            },
            leading: Icon(Icons.person),
            title: RichText(
              text: TextSpan(
                  text: suggestionList[index].substring(0, query.length),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: suggestionList[index].substring(query.length),
                        style: TextStyle(color: Colors.grey))
                  ]),
            )));
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

