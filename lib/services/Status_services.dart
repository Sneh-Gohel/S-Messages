// ignore_for_file: non_constant_identifier_names, camel_case_types, file_names, avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Status_services {
  static Future<void> addStatus(String user_id, File? image) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    try {
      final path = "Status/$user_id/status_image.jpg";

      final ref = FirebaseStorage.instance.ref().child(path);
      UploadTask? up = ref.putFile(image!);
      await up.whenComplete(() {
        var type = FeedbackType.success;
        Vibrate.feedback(type);
        Fluttertoast.showToast(
          msg: "Status has updated...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      });

      FirebaseFirestore.instance
          .collection('Status')
          .doc(user_id)
          .update({'status_image': path, 'status_timestamp': Timestamp.now()});

      FirebaseFirestore.instance
          .collection(user_id)
          .doc('User_information')
          .update({'status': 'Yes'});
    } catch (e) {
      print("Getting exeption : $e");
    }
  }

  Future<void> updateNote(String note, String user_id) async {
    FirebaseFirestore.instance
        .collection('Status')
        .doc(user_id)
        .update({'note': note, 'note_timestamp': Timestamp.now()});

    var type = FeedbackType.success;
    Vibrate.feedback(type);

    Fluttertoast.showToast(
      msg: "Notes has updated...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<bool> autoUpdateStatusAndNotes(String user_id) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Status')
          .doc(user_id)
          .get();

      Timestamp timestamp = docSnapshot.get('status_timestamp');
      DateTime now = DateTime.now();
      DateTime storedTime = timestamp.toDate();

      Duration difference = now.difference(storedTime);

      if (difference.inHours >= 24) {
        FirebaseFirestore.instance.collection('Status').doc(user_id).update({
          'status_image': 'None',
          'status_timestamp': 'None',
          'note': 'New moments...',
          'note_timestamp': 'None'
        });
        FirebaseFirestore.instance
            .collection(user_id)
            .doc('User_information')
            .update({'status': 'no'});
        return true;
      } else {
        print("The timestamp is less than 24 hours old.");
        return false;
      }
    } catch (e) {
      print("Error checking timestamp: $e");
      return false;
    }
  }
}
