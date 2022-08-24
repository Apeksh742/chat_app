import 'package:chat_app/modal/notificationModel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications",
            style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 25)),),
                body: ListView.builder(
                  itemCount: NotificationModel.messages.length,
  
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: Padding(padding: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(NotificationModel.messages[index].notification.title),
                          subtitle: Text(NotificationModel.messages[index].notification.body),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}