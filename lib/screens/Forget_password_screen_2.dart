// ignore_for_file: camel_case_types, file_names, non_constant_identifier_names, must_be_immutable, avoid_print, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:s_messages/screens/Login_screen.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class Forget_password_screen_2 extends StatefulWidget {
  String user_id = "";
  Forget_password_screen_2({super.key, required this.user_id});

  @override
  State<StatefulWidget> createState() => _Forget_password_screen_2();
}

class _Forget_password_screen_2 extends State<Forget_password_screen_2> {
  final password_controller = TextEditingController();
  final password = FocusNode();
  bool password_check = false;
  bool hide_password = true;
  final re_enter_password_controller = TextEditingController();
  final re_enter_password = FocusNode();
  bool re_enter_password_check = false;
  bool hide_re_enter_password = true;
  String first_name = "";
  String last_name = "";
  String mail = "";
  String mobile_number = "";
  String user_name = "";
  String profile_pic = "";
  String about = "";
  String status = "";
  String user_id = "";
  List<Map<String, dynamic>> userInformation = [];
  bool loading_screen = false;

  void change_it_click() {
    if (password_controller.text != "") {
      if (re_enter_password_controller.text != "") {
        if (password_controller.text == re_enter_password_controller.text) {
          setState(() {
            loading_screen = true;
          });
          retrive_data();
        } else {
          var type = FeedbackType.warning;
          Vibrate.feedback(type);
          setState(() {
            password_check = true;
            re_enter_password_check = true;
          });
        }
      } else {
        var type = FeedbackType.warning;
        Vibrate.feedback(type);
        setState(() {
          re_enter_password_check = true;
        });
      }
    } else {
      var type = FeedbackType.warning;
      Vibrate.feedback(type);
      setState(() {
        password_check = true;
      });
    }
  }

  Future<void> retrive_data() async {
    await Firebase.initializeApp();
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(widget.user_id).get();
      for (var doc in querySnapshot.docs) {
        userInformation.add(doc.data() as Map<String, dynamic>);
      }
      for (var data in userInformation) {
        setState(() {
          first_name = data['first_name'].toString();
          last_name = data['last_name'].toString();
          mail = data['mail'].toString();
          mobile_number = data['mobile_number'].toString();
          user_name = data['user_name'].toString();
          profile_pic = data['profile_pic'].toString();
          about = data['about'].toString();
          status = data['status'].toString();
          user_id = data['user_id'].toString();
        });
        updateDocument();
      }
    } catch (e) {
      setState(() {
        loading_screen = false;
      });
      print("Cannot fetch values, exeption : $e");
      const SnackBar(
        content: Text("Cannot update passsword."),
      );
    }
  }

  Future<void> updateDocument() async {
    try {
      final CollectionReference users =
          FirebaseFirestore.instance.collection(widget.user_id);
      // QuerySnapshot querySnapshot = await users.get();
      // String docId = querySnapshot.docs.first.id;
      final DocumentReference docRef = users.doc("User_information");
      await docRef.set({
        'first_name': first_name,
        'last_name': last_name,
        'mail': mail,
        'mobile_number': mobile_number,
        'password': password_controller.text,
        'user_name': user_name,
        'about': about,
        'profile_pic': profile_pic,
        'status': status,
        'user_id': user_id
      });

      print('Document updated successfully!');
      setState(() {
        loading_screen = true;
      });
      page_change();
      const SnackBar(
        content: Text("Document updated successfully!"),
      );
    } catch (e) {
      setState(() {
        loading_screen = false;
      });
      const SnackBar(
        content: Text("Cannot update passsword."),
      );
      print('Error updating document: $e');
    }
  }

  void page_change() // to redirect the user to the home screen.
  {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // return const COA_screen_1();
          return const Login_screen();
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
    Size screenSize = MediaQuery.of(context).size;
    double screen_height = screenSize.height;
    double screen_width = screenSize.width;

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
            height: screen_height,
            width: screen_width,
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: (screen_height / 4)),
                  child: Center(
                    child: GradientText(
                      "New password!",
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      colors: const [Colors.blue, Colors.purple],
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50, left: 40, right: 40),
                  child: TextField(
                    controller: password_controller,
                    focusNode: password,
                    onEditingComplete: () {
                      setState(() {
                        password_check = false;
                      });
                      password.unfocus();
                    },
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: hide_password,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.key,
                          color: Colors.white), // Adjust prefix icon color
                      suffix: GestureDetector(
                        child: Icon(
                            hide_password
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white), // Adjust suffix icon color
                        onTap: () {
                          setState(() {
                            if (hide_password) {
                              hide_password = false;
                            } else {
                              hide_password = true;
                            }
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                password_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                password_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      hintText: "Password",
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
                  padding: const EdgeInsets.only(top: 50, left: 40, right: 40),
                  child: TextField(
                    controller: re_enter_password_controller,
                    focusNode: re_enter_password,
                    onEditingComplete: () {
                      setState(() {
                        re_enter_password_check = false;
                      });
                      re_enter_password.unfocus();
                    },
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: hide_password,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.key,
                          color: Colors.white), // Adjust prefix icon color
                      suffix: GestureDetector(
                        child: Icon(
                            hide_password
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white), // Adjust suffix icon color
                        onTap: () {
                          setState(() {
                            if (hide_password) {
                              hide_re_enter_password = false;
                            } else {
                              hide_re_enter_password = true;
                            }
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: re_enter_password_check
                                ? Colors.purple
                                : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: re_enter_password_check
                                ? Colors.purple
                                : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      hintText: "Re-Enter Password",
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
                  padding:
                      const EdgeInsets.only(top: 70, left: 100, right: 100),
                  child: ElevatedButton(
                    onPressed: () {
                      change_it_click();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      shape: const StadiumBorder(),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Change it",
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
