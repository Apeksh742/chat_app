import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Pages/previewImage.dart';
import 'package:chat_app/Pages/tapImage.dart';
import 'package:chat_app/modal/messageModel.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ConversationScreen extends StatefulWidget {
  final receiverName;
  final chatRoomId;

  ConversationScreen(
      {key: Key, @required this.receiverName, @required this.chatRoomId});
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  Stream chatMessageStream;
  String message;
  File _image;

  final currentUser = FirebaseAuth.instance.currentUser;
  firebase_storage.FirebaseStorage storageInstance =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  TextEditingController messageController = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  Widget buildMessageComposer(BuildContext context,
      TextEditingController controller, String message, String chatRoomId) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          children: [
            IconButton(
                tooltip: "Send image",
                icon: Icon(
                  Icons.photo,
                  color: Colors.red,
                ),
                onPressed: () {
                  _showPicker(context);
                }),
            SizedBox(width: 20),
            Expanded(
                child: TextField(
              onSubmitted: (_) {
                if (controller.text.isNotEmpty) {
                  message = controller.text;
                  // print(message);
                  sendMessasge(
                      context: context,
                      message: message,
                      chatRoomId: chatRoomId);
                  controller.clear();
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                }
              },
              controller: controller,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              decoration: InputDecoration.collapsed(hintText: "Send a message"),
            )),
            IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.red,
                ),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    message = controller.text;
                    // print(message);
                    sendMessasge(
                        context: context,
                        message: message,
                        chatRoomId: chatRoomId
                        // context, message, chatRoomId
                        );
                    controller.clear();
                    SystemChannels.textInput.invokeMethod('TextInput.hide');
                  }
                }),
          ],
        ));
  }

  Widget textOrImageBox(
      MessageModel message, BuildContext context, String sentBy) {
    Timestamp myTimeStamp = message.created;
    // print("My Timestamp: $myTimeStamp");
    DateTime myDateTime = myTimeStamp?.toDate();
    // print("MydateTime: $myDateTime");
    String formattedTime = DateFormat.jm().format(myDateTime ?? DateTime.now());
    // String currentTime = DateFormat.jm().format(DateTime.now());
    // print(formattedTime);
    if (message.isPhoto == true) {
      return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            print("Button Pressed");
            return TapImage(
              downloadUrl: message.message,
            );
          }));
        },
        child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
              maxHeight: MediaQuery.of(context).size.height * 0.25,
            ),
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
                color: sentBy == currentUser.displayName
                    ? Color(0xff4D94FF)
                    : Color(0xffE5E9F0),
                borderRadius: sentBy == currentUser.displayName
                    ? BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10))
                    : BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10))),
            child: Container(
              padding: EdgeInsets.all(5),
              child: CachedNetworkImage(
                  placeholder: (context, url) => Container(
                      height: 100,
                      width: 100,
                      child: Center(
                          child: LoadingIndicator(
                        indicatorType: Indicator.circleStrokeSpin,
                        color: Colors.green,
                      ))),
                  imageUrl: message.message),
            )),
      );
    }
    return Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
            color: sentBy == currentUser.displayName
                ? Color(0xff4D94FF)
                : Color(0xffE5E9F0),
            borderRadius: sentBy == currentUser.displayName
                ? BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10))
                : BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10))),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SelectableText(
              message.message,
              style: TextStyle(
                  color: sentBy == currentUser.displayName
                      ? Colors.white
                      : Colors.black,
                  fontWeight: FontWeight.w400),
              cursorColor: Colors.yellow,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.009),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                Text(formattedTime ?? "",
                    style: TextStyle(color: Colors.black, fontSize: 10)),
              ],
            )
            // FutureBuilder(
            //   future: getTimestamp(querySnapshot[index]),
            //   builder: (BuildContext context, AsyncSnapshot snapshot) {̥
            //     if(snapshot.hasData){
            //       print("Future Builder Snapshot Data: ${snapshot.data}");
            //       return Container(child: Text("${snapshot.data}"));
            //     }
            //     else{
            //       return Container();
            //     }
            //   },
            // ),
          ],
        ));
  }

  void sendMessasge(
      {BuildContext context, bool isPhoto, String message, String chatRoomId}) {
    if (isPhoto != true) {
      isPhoto = false;
    }
    if (message.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      // String timestamp = FieldValue.serverTimestamp().toString();

      Map<String, dynamic> messageMap = {
        "message": message,
        "sentBy": user.displayName,
        "created": FieldValue.serverTimestamp(),
        "isPhoto": isPhoto,
        "users": [widget.receiverName, user.displayName]
      };
      DatabaseMethods().sendMessage(chatRoomId, messageMap);
    }
  }

  Future getImage(bool gallery, BuildContext ctx) async {
    print("SendPhoto Pressed");

    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if (gallery) {
      pickedFile =
          await picker.getImage(source: ImageSource.gallery, imageQuality: 70);
      if (pickedFile != null) {
        // _images.add(File(pickedFile.path));
        _image = File(pickedFile.path); // Use if you only need a single picture
        Navigator.push(ctx, MaterialPageRoute(builder: (ctx) {
          return PreviewPage(
            file: _image,
            chatRoomId: widget.chatRoomId,
            receiverName: widget.receiverName,
          );
        }));
      } else {
        print('No image selected.');
      }
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile =
          await picker.getImage(source: ImageSource.camera, imageQuality: 70);
      if (pickedFile != null) {
        // _images.add(File(pickedFile.path));
        _image = File(pickedFile.path); // Use if you only need a single picture
        Navigator.push(ctx, MaterialPageRoute(builder: (ctx) {
          return PreviewPage(
            file: _image,
            chatRoomId: widget.chatRoomId,
            receiverName: widget.receiverName,
          );
        }));
      } else {
        print('No image selected.');
      }
    }

    setState(() {
      // if (pickedFile != null) {
      //   // _images.add(File(pickedFile.path));
      //   _image = File(pickedFile.path); // Use if you only need a single picture
      //   Navigator.push(ctx, MaterialPageRoute(builder: (ctx) {
      //     return PreviewPage(
      //       file: _image,
      //       chatRoomId: widget.chatRoomId,
      //       receiverName: widget.receiverName,
      //     );
      //   }));
      // } else {
      //   print('No image selected.');
      // }
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Gallery'),
                      onTap: () async {
                        Navigator.pop(context);
                        await getImage(true, context);
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () async {
                      Navigator.pop(context);
                      await getImage(false, context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back)),
            FutureBuilder<QuerySnapshot>(
              future: databaseMethods.findUserbyUsername(widget.receiverName),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data.docs.first.data();

                  if (data.containsKey("profileURL")) {
                    String profileURL =
                        snapshot.data.docs.first.get("profileURL");
                    // developerlog.log(profileURL);
                    return CachedNetworkImage(
                      imageUrl: profileURL,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => CircleAvatar(
                          child: Center(child: CircularProgressIndicator())),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    );
                  }
                  return CircleAvatar(
                      child: Text(widget.receiverName[0].toUpperCase()));
                }
                return CircleAvatar(
                    child: Text(widget.receiverName[0].toUpperCase()));
              },
            ),
            SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName),
                StreamBuilder<QuerySnapshot>(
                  stream: databaseMethods.checkUserStatus(widget.receiverName),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      bool status = snapshot.data.docs.first.get("status");
                      return Container(
                          child: status
                              ? Text(
                                  "Online",
                                  style: TextStyle(fontSize: 12),
                                )
                              : Text("Offline",
                                  style: TextStyle(fontSize: 12)));
                    } else {
                      return Container();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        // actions: [
        //   IconButton(
        //       icon: Icon(
        //         Icons.more_vert,
        //       ),
        //       onPressed: () {}),
        // ],
      ),
      body: GestureDetector(
        onTap: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: StreamBuilder<QuerySnapshot>(
                  stream: DatabaseMethods().showMessages(widget.chatRoomId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot> myQueryList =
                          snapshot.data.docs;
                      List<MessageModel> messages = [];
                      myQueryList.forEach((element) {
                        messages.add(MessageModel(
                            created: element.get("created"),
                            isPhoto: element.get('isPhoto'),
                            message: element.get('message'),
                            sentBy: element.get('sentBy'),
                            users: element.get('users')));
                      });
                      return GroupedListView(
                          elements: messages,
                          groupBy: (MessageModel msg) => DateFormat(
                                  'dd-MM-yyyy')
                              .format(msg.created?.toDate() ?? DateTime.now())
                              .toString(),
                          reverse: true,
                          groupComparator: (String value1, String value2)
                              // value2.compareTo(value1),
                              {
                            String convertedDate1 = value1.substring(6, 10) +
                                "-" +
                                value1.substring(3, 5) +
                                "-" +
                                value1.substring(0, 2);
                            String convertedDate2 = value2.substring(6, 10) +
                                "-" +
                                value2.substring(3, 5) +
                                "-" +
                                value2.substring(0, 2);
                            DateTime date1 = DateTime.parse(convertedDate1);
                            DateTime date2 = DateTime.parse(convertedDate2);
                            return date2.compareTo(date1);
                          },
                          order: GroupedListOrder.ASC,
                          // floatingHeader: true,
                          useStickyGroupSeparators: true,
                          groupSeparatorBuilder: (String value) => Padding(
                                padding: const EdgeInsets.all(8),
                                child: Container(
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          itemBuilder: (context, MessageModel message) =>
                              Column(
                                children: [
                                  Align(
                                    alignment: message.sentBy ==
                                            currentUser.displayName
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: textOrImageBox(
                                      message,
                                      context,
                                      message.sentBy,
                                    ),
                                  )
                                ],
                              ));

                      // return ListView.builder(
                      //     itemCount: messages.length,
                      //     reverse: true,
                      //     itemBuilder: (BuildContext context, int index) {
                      //       String sentBy = messages[index].sentBy;
                      //       Timestamp myTimeStamp = messages[index].created;
                      //       DateTime myDateTime = myTimeStamp?.toDate();
                      //       String formattedTime = DateFormat('dd-MM-yyyy')
                      //           .format(myDateTime ?? DateTime.now());
                      //       int todayCount = 0;
                      //       if (formattedTime.substring(0, 2) ==
                      //           DateFormat('dd-MM-yyyy')
                      //               .format(DateTime.now())
                      //               .substring(0, 2)) {
                      //         todayCount++;
                      //         log(todayCount.toString());
                      //         return Column(
                      //           children: [
                      //             todayCount == 1
                      //                 ? Center(child: Text("Today"))
                      //                 : Container(),
                      //             Align(
                      //               alignment: sentBy == currentUser.displayName
                      //                   ? Alignment.centerRight
                      //                   : Alignment.centerLeft,
                      //               child: textOrImageBox(
                      //                 messages,
                      //                 index,
                      //                 context,
                      //                 sentBy,
                      //               ),
                      //             )
                      //           ],
                      //         );
                      //       } else if (int.parse(
                      //               formattedTime.substring(0, 2)) ==
                      //           int.parse(DateFormat('dd-MM-yyyy')
                      //                   .format(DateTime.now())
                      //                   .substring(0, 2)) -
                      //               1)
                      //         return Column(
                      //           children: [
                      //             Center(child: Text("Yesterday")),
                      //             Align(
                      //               alignment: sentBy == currentUser.displayName
                      //                   ? Alignment.centerRight
                      //                   : Alignment.centerLeft,
                      //               child: textOrImageBox(
                      //                 messages,
                      //                 index,
                      //                 context,
                      //                 sentBy,
                      //               ),
                      //             )
                      //           ],
                      //         );
                      //       else {
                      //         return Column(
                      //           children: [
                      //             Center(child: Text(formattedTime)),
                      //             Align(
                      //               alignment: sentBy == currentUser.displayName
                      //                   ? Alignment.centerRight
                      //                   : Alignment.centerLeft,
                      //               child: textOrImageBox(
                      //                 messages,
                      //                 index,
                      //                 context,
                      //                 sentBy,
                      //               ),
                      //             )
                      //           ],
                      //         );
                      //       }
                      //     });
                    }
                    return Container();
                  }),
              decoration: BoxDecoration(
                color: Color(0xffF2F4F7),
              ),
            )),
            buildMessageComposer(
                context, messageController, message, widget.chatRoomId)
          ],
        ),
      ),
    );
  }
}
