import 'dart:async';
import 'dart:io';
import 'package:chat_app/services/databasemethod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';

class PreviewPage extends StatefulWidget {
  final file,chatRoomId,receiverName;
  const PreviewPage({Key key, this.file,this.chatRoomId,this.receiverName}) : super(key: key);
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  List<File> images=[];
  firebase_storage.FirebaseStorage storageInstance =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  @override
  void initState() { 
    print("Init state of  Preview Image called");
    images.add(widget.file);
    super.initState();
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
      "isPhoto": isPhoto,
      "users": [widget.receiverName,user.displayName]
    };
    DatabaseMethods().sendMessage(chatRoomId, messageMap);
  }
}

  Future<void> saveImages(List<File> _images) async {
    _images.forEach((image) async {
      String imageURL = await uploadFile(image);
      sendMessasge(message: imageURL, chatRoomId: widget.chatRoomId, isPhoto: true
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

 Future getImage(bool gallery,BuildContext ctx)async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    if (gallery) {
      pickedFile =
          await picker.getImage(source: ImageSource.gallery, imageQuality: 70);
          print("Image selected");
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile =
          await picker.getImage(source: ImageSource.camera, imageQuality: 70);
    }
    setState(() {
      print("Set State called inside PageViewer");
      if (pickedFile != null) {
        images.add(File(pickedFile.path));
        //_image = File(pickedFile.path); // Use if you only need a single picture
      } else {
        print('No image selected.');
      }
    });
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20),
                     child: Column(
                       children: [
                         Expanded(
                           child: PageView.builder(itemCount: images.length,itemBuilder: (ctx,index){
                              print("No. of Photos: ${images.length}");
                              return Container(
                                child: Center(
                                  child: Container(
                                    child: Image.file(images[index]))
                                ),
                              );
                            }
                           ),
                         ),
                         Padding(
                           padding: const EdgeInsets.only(top:10),
                           child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children:[
                                Padding(
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 10),
                                  child: CircleAvatar(
                                    radius: 30,
                                    child: IconButton(onPressed: (){
                                      setState(() {
                                         getImage(true, context);
                                      });
                                    },
                                    tooltip: "Add a new photo",
                                    icon: Icon(Icons.add,color: Colors.white,size: 30)),
                                  ) 
                                 ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB( 0,0, 20, 10),
                                  child: CircleAvatar(
                                    radius: 30,
                                    child: IconButton(onPressed: ()async{
                                      await saveImages(images);
                                      print("Save Images Function executed");
                                      Navigator.pop(context);
                                    },
                                    tooltip: "Send",
                                    icon: Icon(Icons.send,color: Colors.white,size: 30,)),
                                  ),
                                )
                              ]
                            ),
                        ),
                         )
                       ],
                     )
                
              )
            ),
    );
  }
}
