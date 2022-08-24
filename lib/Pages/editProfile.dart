import 'dart:developer' as devlog;
import 'dart:io';
import 'dart:math';
import 'package:csc_picker/csc_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/services/databasemethod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:images_picker/images_picker.dart';
import 'package:chat_app/modal/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key key}) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  File _image;
  DateTime selectedDate = DateTime.now();
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String address = "";
  bool isLoading = false;
  List<Media> pickedFile;
  String dateOfBirth;
  User currentUser = FirebaseAuth.instance.currentUser;
  DatabaseMethods database = DatabaseMethods();
  firebase_storage.FirebaseStorage storageInstance =
      firebase_storage.FirebaseStorage.instance;
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  @override
  void didChangeDependencies() {
    devlog.log("Did change dependencies called");

    super.didChangeDependencies();
  }

  Future<void> saveImages(File _image, BuildContext context) async {
    String imageURL = await uploadFile(_image, context);

    database.updateProfilePicture({"profileURL": imageURL}, currentUser.uid);
  }

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime picked = await showDatePicker(
  //       context: context,
  //       initialDate: selectedDate,
  //       firstDate: DateTime(1920, 1),
  //       lastDate: DateTime.now());
  //   if (picked != null && picked != selectedDate)
  //     setState(() {
  //       selectedDate = picked;
  //       dateOfBirth = selectedDate.toLocal().toString();
  //     });
  // }

  Future<String> uploadFile(File _image, BuildContext context) async {
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
    final userInfo = Provider.of<MyUser>(context, listen: false);
    userInfo.updateProfile(profileURL: downloadURL);
    return downloadURL;
  }

  Future getImage(bool gallery, BuildContext ctx) async {
    // Let user select photo from gallery
    if (gallery) {
      pickedFile = await ImagesPicker.pick(
          count: 1,
          cropOpt: CropOption(
            aspectRatio: CropAspectRatio.custom,
            cropType: CropType.circle, // currently for android
          ),
          quality: 0.7,
          maxSize: 500,
          pickType: PickType.image);
    }
    // Otherwise open camera to get new photo
    else {
      pickedFile = await ImagesPicker.openCamera(
        cropOpt: CropOption(
          aspectRatio: CropAspectRatio.custom,
          cropType: CropType.circle, // currently for android
        ),
        pickType: PickType.image,
        quality: 0.7,
        maxSize: 500,
      );
    }

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile[0].path);
      } else {
        print('No image selected.');
      }
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
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
    // final userInfo = Provider.of<MyUser>(context);
    // devlog.log(_image.toString());
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: GoogleFonts.poppins(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        leading: InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.clear,
              color: Colors.black,
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
                onTap: () async {
                  
                  if (_image != null) {
                    setState(() {
                      isLoading = true;
                    });
                    // await Future.delayed(Duration(seconds: 2));
                    await saveImages(_image, context);
                    setState(() {
                      isLoading = false;
                    });
                  }
                  final snackBar = SnackBar(
                    content: const Text('Profile Updated Succesfully'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: LoadingIndicator(
                              indicatorType: Indicator.circleStrokeSpin),
                        ),
                      )
                    : Icon(Icons.check, color: Colors.black)),
          )
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return database.getProfileData(currentUser.uid);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Consumer<MyUser>(builder: (ctx, myUser, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: _height * 0.01,
                          ),
                          // _image == null
                          // ?
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Column(
                                    children: [
                                      _image == null
                                          ? FutureBuilder<QuerySnapshot>(
                                              future: database.getProfileData(
                                                  currentUser.uid),
                                              builder: (BuildContext ctx,
                                                  AsyncSnapshot<QuerySnapshot>
                                                      snapshot) {
                                                devlog.log(
                                                    "Future Builder Profile Called");
                                                if (snapshot.hasData) {
                                                  Map<String, dynamic> data =
                                                      snapshot.data.docs.first
                                                          .data();
                                                  if (data.containsKey(
                                                      "profileURL")) {
                                                    String profileURL = snapshot
                                                        .data.docs.first
                                                        .get("profileURL");
                                                    devlog.log(profileURL);
                                                    return CachedNetworkImage(
                                                      imageUrl: profileURL,
                                                      imageBuilder: (context,
                                                              imageProvider) =>
                                                          Container(
                                                        width: 100.0,
                                                        height: 100.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          image: DecorationImage(
                                                              image:
                                                                  imageProvider,
                                                              fit:
                                                                  BoxFit.cover),
                                                        ),
                                                      ),
                                                      placeholder: (context,
                                                              url) =>
                                                          Container(
                                                              height: 100,
                                                              width: 100,
                                                              child: Center(
                                                                  child:
                                                                      LoadingIndicator(
                                                                indicatorType:
                                                                    Indicator
                                                                        .circleStrokeSpin,
                                                              ))),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    );
                                                  }

                                                  return CircleAvatar(
                                                    radius: 40,
                                                    child: Icon(Icons.person,
                                                        size: 30),
                                                  );
                                                } else {
                                                  return CircleAvatar(
                                                    radius: 40,
                                                    child: Icon(Icons.person,
                                                        size: 30),
                                                  );
                                                }
                                              })
                                          : CircleAvatar(
                                              radius: 40,
                                              backgroundImage:
                                                  FileImage(_image),
                                            ),
                                      SizedBox(
                                        height: _height * 0.02,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          _showPicker(context);
                                        },
                                        child: Text(
                                          "Change Profile Photo",
                                          style: GoogleFonts.poppins(
                                              color: Colors.blue),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: _height * 0.02,
                                ),
                                Text(
                                  "Your Email",
                                  style:
                                      GoogleFonts.poppins(color: Colors.grey),
                                ),
                                TextFormField(
                                  enabled: false,
                                  initialValue: myUser.email,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: _height * 0.02,
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Username",
                                  style:
                                      GoogleFonts.poppins(color: Colors.grey),
                                ),
                                TextFormField(
                                  enabled: false,
                                  initialValue: myUser.username,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: _height * 0.02,
                          ),
                          // Consumer<MyUser>(
                          //     builder: (ctx, usermodel, child) =>
                          //         Text(usermodel.profileURL)),
                          // Container(
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         "Date of Birth",
                          //         style: GoogleFonts.poppins(color: Colors.grey),
                          //       ),
                          //       SizedBox(height: _height * 0.02),
                          //       Row(
                          //         mainAxisAlignment:
                          //             MainAxisAlignment.spaceBetween,
                          //         children: [
                          //           FutureBuilder<QuerySnapshot>(
                          //             future: database
                          //                 .getProfileData(currentUser.uid),
                          //             builder: (BuildContext context,
                          //                 AsyncSnapshot<QuerySnapshot> snapshot) {
                          //               if (snapshot.hasData) {
                          //                 Map<String, dynamic> data =
                          //                     snapshot.data.docs.first.data();
                          //                 if (data.containsKey("DOB")) {
                          //                   dateOfBirth = data["DOB"];
                          //                   return Text(
                          //                     dateOfBirth.split(' ')[0],
                          //                     style: TextStyle(fontSize: 16),
                          //                   );
                          //                 }
                          //                 return LoadingIndicator(
                          //                     indicatorType:
                          //                         Indicator.circleStrokeSpin);
                          //               }
                          //               return Text("Select DOB");
                          //             },
                          //           ),
                          //           // Padding(
                          //           //   padding: const EdgeInsets.only(right: 16),
                          //           //   child: RaisedButton(
                          //           //     onPressed: () {
                          //           //       _selectDate(context);
                          //           //       setState(() {
                          //           //         dateOfBirth =
                          //           //             selectedDate.toLocal().toString();
                          //           //       });
                          //           //     },
                          //           //     child: Text('Change DOB'),
                          //           //   ),
                          //           // ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: _height * 0.02,
                          ),
                          // CSCPicker(
                          //   showStates: true,
                          //   showCities: true,
                          //   flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,

                          //   onCountryChanged: (value) {
                          //     setState(() {
                          //       ///store value in country variable
                          //       countryValue = value;
                          //     });
                          //   },

                          //   ///triggers once state selected in dropdown
                          //   onStateChanged: (value) {
                          //     setState(() {
                          //       ///store value in state variable
                          //       stateValue = value;
                          //     });
                          //   },

                          //   ///triggers once city selected in dropdown
                          //   onCityChanged: (value) {
                          //     setState(() {
                          //       ///store value in city variable
                          //       cityValue = value;
                          //     });
                          //   },
                          // )
                          // Container(
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         "Your City",
                          //         style: GoogleFonts.poppins(color: Colors.grey),
                          //       ),
                          //       TextFormField(
                          //         initialValue: "Enter City",
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: _height * 0.02,
                          // ),
                          // Container(
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Text(
                          //         "Your Country",
                          //         style: GoogleFonts.poppins(color: Colors.grey),
                          //       ),
                          //       TextFormField(
                          //         initialValue: "Enter Country",
                          //       ),
                          //     ],
                          //   ),
                          // )
                        ],
                      );
                    })),
                SizedBox(
                  height: _height * 0.02,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
