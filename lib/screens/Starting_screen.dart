// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names, unused_import, use_build_context_synchronously, unused_element, unused_local_variable, empty_catches, unused_field, avoid_print

import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:s_messages/screens/Home_screen.dart';
import 'package:s_messages/screens/Login_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Starting_screen extends StatefulWidget {
  const Starting_screen({super.key});

  @override
  State<StatefulWidget> createState() => _Starting_screen();
}

class _Starting_screen extends State<Starting_screen> {
  late Timer _timer;
  late ConnectivityResult _connectionStatus;
  String mobile_number = "";
  String password = "";
  String user_id = "";
  List<Map<String, dynamic>> userInformation = [];

  Future<void> checkInternetConnection() async {
    ConnectivityResult result = await Connectivity().checkConnectivity();
    setState(() {
      _connectionStatus = result;
    });
    if (_connectionStatus == ConnectivityResult.none) {
      _showNoInternetDialog();
    }
  }

  Future<void> _showNoInternetDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('No Internet Connection!'),
          content: const Text('Please check your internet connection.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                checkInternetConnection(); // Retry
              },
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Exit the application
              },
              child: const Text(
                'Exit',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> verify_user() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    bool verified = false;
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("Verified_mobile_numbers")
          .get();

      for (var doc in querySnapshot.docs) {
        userInformation.add(doc.data() as Map<String, dynamic>);
      }
      for (var data in userInformation) {
        data.forEach((key, value) {
          if (mobile_number == key) {
            setState(() {
              user_id = value;
            });
          }
        });
      }

      querySnapshot =
          await FirebaseFirestore.instance.collection(user_id).get();

      for (var doc in querySnapshot.docs) {
        userInformation.add(doc.data() as Map<String, dynamic>);
      }
      for (var data in userInformation) {
        if (data['password'] == password) {
          setState(() {

            verified = true;
          });
        }
      }
    } catch (e) {
      print("Failed to fetch data: $e");
    }

    return verified;
  }

  void screen_changer() {
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) async {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/user_id.txt');
        bool fileExists = file.existsSync();
        if (fileExists) {
          String file_content = "";
          try {
            file_content = await file.readAsString();
            List<String> splitStrings = file_content.split(" ");
            mobile_number = splitStrings[0];
            password = splitStrings[1];
            if (await verify_user()) {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return Home_screen(user_id: user_id,);
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
                (route) => false,
              );
            } else {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    // return const COA_screen_1();
                    return const Login_screen();
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
                (route) => false,
              );
            }
          } catch (e) {
            print("Error in auto_login.");
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  // return const COA_screen_1();
                  return const Login_screen();
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
              (route) => false,
            );
          }
        } else {
          print("No file found.");
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                // return const COA_screen_1();
                return const Login_screen();
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
            (route) => false,
          );
        }
        timer.cancel();
      },
    );
  }

  @override
  void initState() {
    super.initState();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectionStatus = result;
      });
      if (_connectionStatus == ConnectivityResult.none) {
        var type = FeedbackType.warning;
        Vibrate.feedback(type);
        _showNoInternetDialog();
      } else {
        screen_changer();
      }
    });
    // Initial check
    checkInternetConnection();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screen_height = screenSize.height;
    double screen_width = screenSize.width;
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            height: screen_height,
            width: screen_width,
            duration: const Duration(),
            decoration: const BoxDecoration(color: Colors.black),
            child: Center(
              child: Hero(
                tag: "Logo",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    "photos/System/Full_S_Messages_logo_final.png",
                    height:
                        300 < screen_height ? 300 : (60 * screen_width) / 100,
                    width: 300 < screen_width ? 300 : (60 * screen_width) / 100,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: (screen_width / 2) - 25,
            child: AnimatedContainer(
              duration: const Duration(),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: const Center(
                child: SpinKitFadingCircle(
                  size: 55,
                  color: Colors.white,
                  // itemCount: 5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
