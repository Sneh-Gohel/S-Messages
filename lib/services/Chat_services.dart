// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:s_messages/services/FCMService.dart';
import 'package:s_messages/services/Message.dart';

class Chat_services {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
      String sender_id,
      String reciver_id,
      String message,
      String chat_id,
      String current_user_name,
      String reason,
      String reciver_fcm) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final Timestamp timestamp = Timestamp.now();
      final FCMService fcmService = FCMService(
        'asset/fir-messages-66053-firebase-adminsdk-exu43-115940ef4c.json',
        'fir-messages-66053',
      );

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

      // updating notification fields and sending notification...

      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Chat_rooms')
          .doc(chat_id)
          .get();
      var chat_details = docSnapshot.data() as Map<String, dynamic>;

      // Sending notificaiton...

      // sending friend request message...
      if (reason == 'friend_request') {
        fcmService.sendNotification(
          'New friend request...',
          "$current_user_name wants to be your friend.",
          reciver_fcm,
        );
        print("message sent...");
      }

      // sending new chat message...
      if (chat_details['${reciver_id}_state'] == "offline") {
        if (reason == 'chat') {
          fcmService.sendNotification(
            current_user_name,
            message,
            reciver_fcm,
          );
          print("message sent...");
        }
      }

      // updadating notification fields...
      if (chat_details['${reciver_id}_state'] == 'offline') {
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
      }
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
