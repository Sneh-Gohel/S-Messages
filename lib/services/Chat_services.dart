// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:s_messages/services/Message.dart';

class Chat_services {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(String sender_id, String reciver_id, String message,
      String chat_id) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final Timestamp timestamp = Timestamp.now();

      Message new_message = Message(
        sender_id: sender_id,
        receiver_id: reciver_id,
        message: message,
        timestamp: timestamp,
      );

      await firestore
          .collection('Chat_rooms')
          .doc(chat_id)
          .collection('messages')
          .add(new_message.toMap());

      // updating notification fields...

      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Chat_rooms')
          .doc(chat_id)
          .get();
      var chat_details = docSnapshot.data() as Map<String, dynamic>;

      if (chat_details[reciver_id] == "No") {
        await FirebaseFirestore.instance
            .collection('Chat_rooms')
            .doc(chat_id)
            .update({reciver_id: 'Yes'});

        await FirebaseFirestore.instance
            .collection('Chat_rooms')
            .doc(chat_id)
            .update({'${reciver_id}_timestamp': timestamp});
      }

      print("message sent...");
    } catch (e) {
      print("Getting exception : $e");
    }
  }

  Stream<QuerySnapshot> getMessages(
      String sender_id, String reciver_id, String chat_id) {
    return firestore
        .collection('Chat_rooms')
        .doc(chat_id)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
