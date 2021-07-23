import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MessageModel {
  final Timestamp created;
  final bool isPhoto;
  final String message;
  final String sentBy;
  final List users;

  MessageModel(
      {this.created, this.isPhoto, this.message, this.sentBy, this.users});
}
