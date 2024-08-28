// ignore_for_file: file_names, camel_case_types, unused_local_variable, non_constant_identifier_names, must_be_immutable, avoid_print, avoid_web_libraries_in_flutter, prefer_typing_uninitialized_variables

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:s_messages/screens/Home_screen.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Verify_otp_screen extends StatefulWidget {
  String first_name = "";
  String last_name = "";
  String mail = "";
  String mobile_number = "";
  String password = "";
  String otp = "";
  Verify_otp_screen(
      {super.key,
      required this.first_name,
      required this.last_name,
      required this.mail,
      required this.mobile_number,
      required this.password,
      required this.otp});

  @override
  State<StatefulWidget> createState() => _Verify_otp_screen();
}

class _Verify_otp_screen extends State<Verify_otp_screen> {
  final otp_controller = TextEditingController();
  final otp = FocusNode();
  bool otp_check = false;
  String user_id = "";
  var status;
  bool loading_screen = false;
  bool otp_visiable = false;

  void verify_click() {
    if (otp_controller.text != "") {
      setState(() {
        loading_screen = true;
      });
      verify();
    } else {
      setState(() {
        otp_check = true;
      });
      var type = FeedbackType.warning;
      Vibrate.feedback(type);
    }
  }

  Future<void> verify() async {
    try {
      await Firebase.initializeApp();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.otp, smsCode: otp_controller.text);
      FirebaseAuth.instance.signInWithCredential(credential).then((value) {
        setState(() {
          user_id = value.user!.uid;
        });
        store_verified_mobile_number();
        store_user_details();
      });
    } catch (e) {
      setState(() {
        loading_screen = false;
      });
      const SnackBar(
        content: Text("Cannot verify user"),
      );
    }
  }

  Future<void> store_verified_mobile_number() async {
    // Name of the collection
    String collectionName = "Verified_mobile_numbers";

    // Data to be added to the collection
    Map<String, dynamic> data = {widget.mobile_number: user_id};

    // Reference to the Firestore collection
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(collectionName);

    // Check if the collection already exists
    bool collectionExists = await doesCollectionExist(collectionRef);

    // If the collection doesn't exist, create it
    if (!collectionExists) {
      await collectionRef.doc().set(<String, dynamic>{});
    }

    // Add data to the collection
    await collectionRef.add(data);
  }

  Future<bool> doesCollectionExist(CollectionReference collectionRef) async {
    // Get the first document from the collection
    QuerySnapshot querySnapshot = await collectionRef.limit(1).get();

    // If the query returns any documents, the collection exists
    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> store_user_details() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference docRef =
          firestore.collection(user_id).doc("User_information");

      await docRef.set({
        'first_name': widget.first_name,
        'last_name': widget.last_name,
        'mail': widget.mail,
        'mobile_number': widget.mobile_number,
        'password': widget.password,
        'user_name': '${widget.first_name} ${widget.last_name}',
        'about': 'Hey! I am on S Messages.',
        'profile_pic': '/profilePhoto/Defalt_image.jpg',
        'status': 'no'
      });

      print('User added to Firestore successfully!');
      create_chat_document();
      create_status_document();
      generate_auto_login_file();
    } catch (e) {
      setState(() {
        loading_screen = false;
      });
      SnackBar(
        content: Text("Error adding data to Firestore: $e"),
      );
    }
  }

  Future<void> create_chat_document() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference docRef =
          firestore.collection(user_id).doc("Chat_information");

      await docRef.set({
        'None': "None",
      });

      print('User added to Firestore successfully!');
    } catch (e) {
      setState(() {
        loading_screen = false;
      });
      SnackBar(
        content: Text("Error adding data to Firestore: $e"),
      );
    }
  }

  Future<void> create_status_document() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference docRef = firestore.collection('Status').doc(user_id);

    await docRef.set({
      'status': 'None',
      'note': 'New moments...',
      'status_timestamp': 'None',
      'note_timestamp': 'None'
    });
  }

  Future<void> generate_auto_login_file() async {
    try {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;
      final storageStatus = android.version.sdkInt < 33
          ? await Permission.storage.request()
          : PermissionStatus.granted;
      print(storageStatus == PermissionStatus.granted);
      if (storageStatus == PermissionStatus.granted) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/user_id.txt');
        await file.writeAsString("${widget.mobile_number} ${widget.password}");
        print("File is generated");
      } else {
        print("File is not generated.");
      }
      page_change();
    } catch (e) {
      // setState(() {
      //   loading_screen = false;
      // });
      SnackBar(
        content: Text("Error generating login file. Exception: $e"),
      );
    }
  }

  void page_change() {
    setState(() {
      loading_screen = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Home_screen(user_id: user_id);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          var scaleAnimation =
              Tween<double>(begin: 0.0, end: 1.0).animate(animation);
          return SlideTransition(
            // opacity: animation,
            // scale: scaleAnimation,
            position: offsetAnimation,
            child: child,
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(),
            decoration: const BoxDecoration(color: Colors.black),
            child: ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Center(
                    child: GradientText(
                      "Verify!",
                      style: const TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      colors: const [Colors.purple, Colors.blue],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Center(
                    child: Text(
                      "We have send you a otp on your entered number...",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 40, right: 40),
                  child: TextField(
                    controller: otp_controller,
                    focusNode: otp,
                    onEditingComplete: () {
                      otp.unfocus();
                    },
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.key,
                          color: Colors.white), // Adjust prefix icon color
                      suffix: GestureDetector(
                        child: Icon(
                            otp_visiable
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white),
                        onTap: () {
                          if (otp_visiable == true) {
                            otp_visiable = false;
                          } else {
                            otp_visiable = true;
                          }
                        },
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: otp_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      hintText: "otp",
                      hintStyle: const TextStyle(
                          color: Colors.white), // Set hint text color
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20), // Adjust content padding
                      // errorBorder: InputBorder.none,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                            color: Colors.white), // Set border color
                      ),
                    ),
                    style:
                        const TextStyle(color: Colors.white), // Set text color
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Resend OTP",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 20, left: 100, right: 100),
                  child: ElevatedButton(
                    onPressed: () {
                      verify_click();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      shape: const StadiumBorder(),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Vetify",
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading_screen
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(126, 0, 0, 0),
                  ),
                  child: const SpinKitCircle(
                    size: 45,
                    color: Colors.white,
                  ),
                )
              : const Center(),
        ],
      ),
    );
  }
}
