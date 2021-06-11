import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/Pages/tapImage.dart';
import 'package:flutter/scheduler.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:path/path.dart';
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
  List<File> _images = [];
  final currentUser = FirebaseAuth.instance.currentUser;
  firebase_storage.FirebaseStorage storageInstance =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  TextEditingController messageController = TextEditingController();
  DatabaseMethods databaseMethods = DatabaseMethods();
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //                              scrollController.animateTo(
    // scrollController.position.maxScrollExtent,
    // duration: Duration(seconds: 1),
    // curve: Curves.fastOutSlowIn,
    // );
    

    //    });
    // if (scrollController.hasClients) {
    //   scrollController.animateTo(scrollController.position.maxScrollExtent,
    //       duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
    //   // Future.delayed(Duration(milliseconds: 50), () {
    //   //   scrollController?.jumpTo(scrollController.position.maxScrollExtent);
    //   // });
    // }
    
  }

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
    scrollController.dispose();
  }

  Widget buildMessageComposer(BuildContext context,
      TextEditingController controller, String message, String chatRoomId) {
    return Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(color: Colors.white),
        child: Row(
          children: [
            IconButton(
                icon: Icon(
                  Icons.photo,
                  color: Colors.red,
                ),
                onPressed: () {
                  getImage(true);
                }),
            SizedBox(width: 20),
            Expanded(
                child: TextField(
              onSubmitted: (_) {
                if (controller.text.isNotEmpty) {
                  message = controller.text;
                  print(message);
                  sendMessasge(
                      context: context, message: message, chatRoomId: chatRoomId
                      // context, message, chatRoomId
                      );
                  controller.clear();
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                }
              },
              controller: controller,
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
                    print(message);
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

  Widget textOrImageBox(List<QueryDocumentSnapshot> querySnapshot, int index,
      BuildContext context, String sentBy) {
    if (querySnapshot[index].get("isPhoto") == true) {
      return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context){
            print("Button Pressed");
            return TapImage(downloadUrl: querySnapshot[index].get('message'),);
          }));
        },
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
            maxHeight:  MediaQuery.of(context).size.height * 0.3,
          ),
          margin: EdgeInsetsDirectional.all(5.0),
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
                      bottomRight: Radius.circular(10))
          ),
          child: Container(
            padding: EdgeInsetsDirectional.all(5),
            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                  height: 100,
                                  width: 100,
                                  child: Center(
                                      child: LoadingIndicator(
                                    indicatorType: Indicator.circleStrokeSpin,
                                    color: Colors.green,
                                  ))),
                              imageUrl: querySnapshot[index].get('message')
                            ),
          )
        ),
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
        child: Text(
          querySnapshot[index].get('message'),
          style: TextStyle(
              color: sentBy == currentUser.displayName
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w400),
        ));
  }

  Future getImage(bool gallery) async {
    print("SendPhoto Pressed");

    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    // Let user select photo from gallery
    if (gallery) {
      pickedFile =
          await picker.getImage(source: ImageSource.gallery, imageQuality: 85);
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile =
          await picker.getImage(source: ImageSource.camera, imageQuality: 85);
    }

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
        //_image = File(pickedFile.path); // Use if you only need a single picture
      } else {
        print('No image selected.');
      }
    });
    await saveImages(_images);
  }

  Future<void> saveImages(List<File> _images) async {
    _images.forEach((image) async {
      String imageURL = await uploadFile(image);
      sendMessasge(message: imageURL, chatRoomId: widget.chatRoomId, isPhoto: true
          // context, message, chatRoomId
          );
    });
  }

  Future<String> uploadFile(File _image) async {
    String downloadURL;
    firebase_storage.Reference storageReference =
        storageInstance.ref().child('uploads/${basename(_image.path)}');
    firebase_storage.UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.then((_) {
      print('File Uploaded');
    });
    // String returnURL;
    await storageReference.getDownloadURL().then((fileURL) {
      downloadURL = fileURL;
    });
    return downloadURL;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        actions: [
          IconButton(icon: Icon(Icons.call), onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.more_vert,
              ),
              onPressed: () {}),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Column(
          children: [
            Expanded(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: StreamBuilder(
                  stream: DatabaseMethods().showMessages(widget.chatRoomId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      List<QueryDocumentSnapshot> myQueryList =
                          snapshot.data.docs;
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: myQueryList.length,
                        itemBuilder: (BuildContext context, int index) {
                          String sentBy = myQueryList[index].get("sentBy");
                          return Align(
                            alignment: sentBy == currentUser.displayName
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: textOrImageBox(
                                myQueryList, index, context, sentBy),
                          );
                        },
                      );
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

void sendMessasge(
    {BuildContext context, bool isPhoto, String message, String chatRoomId}) {
  if (isPhoto != true) {
    isPhoto = false;
  }
  if (message.isNotEmpty) {
    final user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic> messageMap = {
      "message": message,
      "sentBy": user.displayName,
      "created": FieldValue.serverTimestamp(),
      "isPhoto": isPhoto
    };
    DatabaseMethods().sendMessage(chatRoomId, messageMap);
  }
}


