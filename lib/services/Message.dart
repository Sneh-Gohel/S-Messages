// ignore_for_file: non_constant_identifier_names, file_names, empty_constructor_bodies

import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  late String sender_id;
  late String receiver_id;
  late String message;
  late Timestamp timestamp;

  Message({
    required this.sender_id,
    required this.receiver_id,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    Map<String, dynamic> temp = {
      'sender_id': sender_id,
      'receiver_id': receiver_id,
      'message': message,
      "timestamp": timestamp
    };
    return temp;
  }
}
