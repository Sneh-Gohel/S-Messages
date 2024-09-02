// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names, unused_local_variable, avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:s_messages/screens/Forget_password_screen.dart';
import 'package:s_messages/screens/Home_screen.dart';
import 'package:s_messages/screens/Signup_screen.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class Login_screen extends StatefulWidget {
  const Login_screen({super.key});

  @override
  State<StatefulWidget> createState() => _Login_screen();
}

class _Login_screen extends State<Login_screen> {
  final user_id_controller = TextEditingController();
  final user_id = FocusNode();
  final password_controller = TextEditingController();
  final password = FocusNode();
  bool user_id_check = false;
  bool password_check = false;
  bool hide_password = true;
  List<Map<String, dynamic>> userInformation = [];
  String user_id_verify = "";
  bool loading_screen = false;
  bool user_find = false;
  String mail = "";
  bool is_page_changed_to_home = false;

  Future<void> _showInvalidUseridDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invalid UserId!'),
          content: const Text('Please enter registred mobile number.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showInvalidPasswordDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invalid Password!'),
          content: const Text('Please check your password once.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void signup_click() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // return const COA_screen_1();
          return const Signup_screen();
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
    );
  }

  void login_click() {
    if (user_id_controller.text != "") {
      if (password_controller.text != "") {
        setState(() {
          loading_screen = true;
        });
        verify_user();
      } else {
        setState(() {
          password_check = true;
        });
        var type = FeedbackType.warning;
        Vibrate.feedback(type);
      }
    } else {
      setState(() {
        user_id_check = true;
      });
      var type = FeedbackType.warning;
      Vibrate.feedback(type);
    }
  }

  Future<void> verify_user() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Verified_mobile_numbers")
          .get();

      for (var doc in querySnapshot.docs) {
        userInformation.add(doc.data() as Map<String, dynamic>);
      }
      for (var data in userInformation) {
        data.forEach((key, value) {
          if (user_id_controller.text == key) {
            setState(() {
              user_id_verify = value;
            });
          } else {
            setState(() {
              loading_screen = false;
              user_id_check = true;
              var type = FeedbackType.warning;
              Vibrate.feedback(type);
              _showInvalidUseridDialog();
            });
          }
        });
      }

      querySnapshot =
          await FirebaseFirestore.instance.collection(user_id_verify).get();

      for (var doc in querySnapshot.docs) {
        userInformation.add(doc.data() as Map<String, dynamic>);
      }
      for (var data in userInformation) {
        if (data['password'] == password_controller.text) {
          setState(() {
            loading_screen = false;
            is_page_changed_to_home = true;
          });

          // Get the device FCM token
          final firebaseMessaging = FirebaseMessaging.instance;
          final fcm = await firebaseMessaging.getToken();

          // update fcm
          final CollectionReference users =
              FirebaseFirestore.instance.collection(data['user_id']);
          final DocumentReference docRef = users.doc("User_information");
          await docRef.set({
            'first_name': data['first_name'],
            'last_name': data['last_name'],
            'mail': data['mail'],
            'mobile_number': data['mobile_number'],
            'password': password_controller.text,
            'user_name': data['user_name'],
            'about': data['about'],
            'profile_pic': data['profile_pic'],
            'status': data['status'],
            'user_id': data['user_id'],
            'fcm': fcm,
          });

          // generate auto login file
          generate_auto_login_file();

          // change login page to home screen.
          page_change();
        }
      }
      if (is_page_changed_to_home == false) {
        setState(() {
          loading_screen = false;
          password_check = true;
          var type = FeedbackType.warning;
          Vibrate.feedback(type);
          _showInvalidPasswordDialog();
        });
      }
    } catch (e) {
      setState(() {
        loading_screen = false;
      });
      print("Failed to fetch data: $e");
    }
  }

  Future<void> generate_auto_login_file() async {
    try {
      final plugin = DeviceInfoPlugin();
      final android = await plugin.androidInfo;
      final storageStatus = android.version.sdkInt < 33
          ? await Permission.storage.request()
          : PermissionStatus.granted;
      if (storageStatus == PermissionStatus.granted) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/user_id.txt');
        await file.writeAsString(
            "${user_id_controller.text} ${password_controller.text}");
        print("File is generated");
      } else {
        print("File is not generated.");
      }
      page_change();
    } catch (e) {
      SnackBar(
        content: Text("Error generating login file. Exception: $e"),
      );
    }
  }

  void page_change() // to redirect the user to the home screen.
  {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          // return const COA_screen_1();
          return Home_screen(
            user_id: user_id_verify,
          );
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

  Future<void> forget_password_click() async {
    if (user_id_controller.text != "") {
      await Firebase.initializeApp();
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection("Verified_mobile_numbers")
            .get();

        for (var doc in querySnapshot.docs) {
          userInformation.add(doc.data() as Map<String, dynamic>);
        }
        for (var data in userInformation) {
          data.forEach(
            (key, value) {
              if (user_id_controller.text == key.toString()) {
                setState(() {
                  user_id_verify = value;
                  user_find = true;
                });
              }
            },
          );
        }
        print("$user_find 1");

        print(user_find);
        if (user_find == true) {
          querySnapshot =
              await FirebaseFirestore.instance.collection(user_id_verify).get();

          for (var doc in querySnapshot.docs) {
            userInformation.add(doc.data() as Map<String, dynamic>);
          }
          for (var data in userInformation) {
            setState(() {
              mail = data['mail'].toString();
            });
          }
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return Forgot_password_screen(
                  mobile_number: user_id_controller.text,
                  user_id: user_id_verify,
                  mail: mail,
                );
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
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
          );
        } else {
          setState(() {
            loading_screen = false;
            user_id_check = true;
            var type = FeedbackType.warning;
            Vibrate.feedback(type);
            _showInvalidUseridDialog();
          });
        }
      } catch (e) {
        print("Error to fetch user details. Exeption : $e");
      }
    } else {
      setState(() {
        loading_screen = false;
        user_id_check = true;
        var type = FeedbackType.warning;
        Vibrate.feedback(type);
        _showInvalidUseridDialog();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    user_find = false;
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screen_height = screenSize.height;
    double screen_width = screenSize.width;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: screen_height,
            width: screen_width,
            decoration: const BoxDecoration(color: Colors.black),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Container(
                    decoration: const BoxDecoration(color: Colors.transparent),
                    child: Center(
                      child: Hero(
                        tag: "Logo",
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            "photos/System/Full_S_Messages_logo_final.png",
                            height: 196.5 < screen_height
                                ? 196.5
                                : (50 * screen_width) / 100,
                            width: 196.5 < screen_width
                                ? 196.5
                                : (50 * screen_width) / 100,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Center(
                    child: GradientText(
                      "Login",
                      style: const TextStyle(
                        fontSize: 45,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      colors: const [Colors.blue, Colors.purple],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 40, right: 40),
                  child: TextField(
                    controller: user_id_controller,
                    focusNode: user_id,
                    onEditingComplete: () {
                      user_id_check = false;
                      if (password_controller.text == "") {
                        FocusScope.of(context).requestFocus(password);
                      } else {
                        user_id.unfocus();
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.call,
                          color: Colors.white), // Adjust prefix icon color
                      suffix: GestureDetector(
                        child: const Icon(Icons.clear,
                            color: Colors.white), // Adjust suffix icon color
                        onTap: () {
                          user_id_controller.clear();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: user_id_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: user_id_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      hintText: "Mobile Number",
                      hintStyle: const TextStyle(
                          color: Colors.white), // Set hint text color
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 20), // Adjust content padding
                      // errorBorder: InputBorder.none,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                        borderSide: const BorderSide(
                            color: Colors.white), // Set border color
                      ),
                    ),
                    style:
                        const TextStyle(color: Colors.white), // Set text color
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 40, right: 40),
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
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                    onPressed: () {
                      forget_password_click();
                    },
                    child: const Text(
                      "Forget Password?",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 20, left: 100, right: 100),
                  child: ElevatedButton(
                    onPressed: () {
                      login_click();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      shape: const StadiumBorder(),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 50, right: 20, bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () {
                          signup_click();
                        },
                        child: const Text("Signup",
                            style: TextStyle(fontSize: 16)),
                      ),
                    ],
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
