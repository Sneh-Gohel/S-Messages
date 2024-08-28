// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names, unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:s_messages/screens/Verify_otp_screen.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class Signup_screen extends StatefulWidget {
  const Signup_screen({super.key});

  @override
  State<StatefulWidget> createState() => _Signup_screen();
}

class _Signup_screen extends State<Signup_screen> {
  final first_name_controller = TextEditingController();
  final last_name_controller = TextEditingController();
  final mail_controller = TextEditingController();
  final mobile_number_controller = TextEditingController();
  final password_controller = TextEditingController();
  final re_enter_password_controller = TextEditingController();
  final first_name = FocusNode();
  final last_name = FocusNode();
  final mail = FocusNode();
  final mobile_number = FocusNode();
  final password = FocusNode();
  final re_enter_password = FocusNode();
  bool first_name_check = false;
  bool last_name_check = false;
  bool mail_check = false;
  bool mobile_number_check = false;
  bool password_check = false;
  bool re_enter_password_check = false;
  bool loading_screen = false;
  bool hide_password = true;
  bool hide_re_entered_password = true;

  void page_change(String verification_id) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return Verify_otp_screen(
            first_name: first_name_controller.text,
            last_name: last_name_controller.text,
            mail: mail_controller.text,
            mobile_number: mobile_number_controller.text,
            password: password_controller.text,
            otp: verification_id,
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
    );
  }

  Future<void> create_new_user() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await FirebaseAuth.instance.verifyPhoneNumber(
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          print("verificatino faild. error is : $e");
          setState(() {
            loading_screen = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            loading_screen = false;
          });
          page_change(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        phoneNumber: ("+91 ${mobile_number_controller.text}"));
  }

  void signup_click() {
    if (first_name_controller.text != "") {
      if (last_name_controller.text != "") {
        if (mail_controller.text != "") {
          if (mobile_number_controller.text != "") {
            if (password_controller.text != "") {
              if (re_enter_password_controller.text != "") {
                if (password_controller.text ==
                    re_enter_password_controller.text) {
                  setState(() {
                    loading_screen = true;
                  });
                  create_new_user();
                } else {
                  setState(() {
                    password_check = true;
                    re_enter_password_check = true;
                  });
                  var type = FeedbackType.warning;
                  Vibrate.feedback(type);
                }
              } else {
                setState(() {
                  re_enter_password_check = true;
                });
                var type = FeedbackType.warning;
                Vibrate.feedback(type);
              }
            } else {
              setState(() {
                password_check = true;
              });
              var type = FeedbackType.warning;
              Vibrate.feedback(type);
            }
          } else {
            setState(() {
              mobile_number_check = true;
            });
            var type = FeedbackType.warning;
            Vibrate.feedback(type);
          }
        } else {
          setState(() {
            mail_check = true;
          });
          var type = FeedbackType.warning;
          Vibrate.feedback(type);
        }
      } else {
        setState(() {
          last_name_check = true;
        });
        var type = FeedbackType.warning;
        Vibrate.feedback(type);
      }
    } else {
      setState(() {
        first_name_check = true;
      });
      var type = FeedbackType.warning;
      Vibrate.feedback(type);
    }
  }

  @override
  void initState() {
    super.initState();
    first_name_controller.clear();
    last_name_controller.clear();
    mail_controller.clear();
    mobile_number_controller.clear();
    password_controller.clear();
    re_enter_password_controller.clear();
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
          Container(
            height: screen_height,
            width: screen_width,
            decoration: const BoxDecoration(color: Colors.black),
            child: ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Center(
                    child: GradientText(
                      "Welcome!",
                      style: const TextStyle(
                        fontSize: 55,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                      colors: const [Colors.purple, Colors.blue],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30, left: 40, right: 40),
                  child: TextField(
                    controller: first_name_controller,
                    focusNode: first_name,
                    onEditingComplete: () {
                      setState(() {
                        first_name_check = false;
                      });
                      if (last_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(last_name);
                      } else if (mail_controller.text == "") {
                        FocusScope.of(context).requestFocus(mail);
                      } else if (mobile_number_controller.text == "") {
                        FocusScope.of(context).requestFocus(mobile_number);
                      } else if (password_controller.text == "") {
                        FocusScope.of(context).requestFocus(password);
                      } else if (re_enter_password_controller.text == "") {
                        FocusScope.of(context).requestFocus(re_enter_password);
                      } else {
                        first_name.unfocus();
                      }
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person,
                          color: Colors.white), // Adjust prefix icon color
                      suffix: GestureDetector(
                        child: const Icon(Icons.clear,
                            color: Colors.white), // Adjust suffix icon color
                        onTap: () {
                          first_name_controller.clear();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                first_name_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                first_name_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      hintText: "First Name",
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
                    controller: last_name_controller,
                    focusNode: last_name,
                    onEditingComplete: () {
                      setState(() {
                        last_name_check = false;
                      });
                      if (first_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(last_name);
                      } else if (mail_controller.text == "") {
                        FocusScope.of(context).requestFocus(mail);
                      } else if (mobile_number_controller.text == "") {
                        FocusScope.of(context).requestFocus(mobile_number);
                      } else if (password_controller.text == "") {
                        FocusScope.of(context).requestFocus(password);
                      } else if (re_enter_password_controller.text == "") {
                        FocusScope.of(context).requestFocus(re_enter_password);
                      } else {
                        last_name.unfocus();
                      }
                    },
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person,
                          color: Colors.white), // Adjust prefix icon color
                      suffix: GestureDetector(
                        child: const Icon(Icons.clear,
                            color: Colors.white), // Adjust suffix icon color
                        onTap: () {
                          last_name_controller.clear();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                last_name_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                last_name_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      hintText: "Last Name",
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
                    controller: mail_controller,
                    focusNode: mail,
                    onEditingComplete: () {
                      setState(() {
                        mail_check = false;
                      });
                      if (last_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(last_name);
                      } else if (first_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(mail);
                      } else if (mobile_number_controller.text == "") {
                        FocusScope.of(context).requestFocus(mobile_number);
                      } else if (password_controller.text == "") {
                        FocusScope.of(context).requestFocus(password);
                      } else if (re_enter_password_controller.text == "") {
                        FocusScope.of(context).requestFocus(re_enter_password);
                      } else {
                        mail.unfocus();
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.mail,
                          color: Colors.white), // Adjust prefix icon color
                      suffix: GestureDetector(
                        child: const Icon(Icons.clear,
                            color: Colors.white), // Adjust suffix icon color
                        onTap: () {
                          mail_controller.clear();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: mail_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: mail_check ? Colors.purple : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      hintText: "Enter Your Mail.",
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
                    controller: mobile_number_controller,
                    focusNode: mobile_number,
                    onEditingComplete: () {
                      setState(() {
                        mobile_number_check = false;
                      });
                      if (last_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(last_name);
                      } else if (mail_controller.text == "") {
                        FocusScope.of(context).requestFocus(mail);
                      } else if (first_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(mobile_number);
                      } else if (password_controller.text == "") {
                        FocusScope.of(context).requestFocus(password);
                      } else if (re_enter_password_controller.text == "") {
                        FocusScope.of(context).requestFocus(re_enter_password);
                      } else {
                        mobile_number.unfocus();
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
                          mobile_number_controller.clear();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.black,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: mobile_number_check
                                ? Colors.purple
                                : Colors.blue),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: mail_check ? Colors.purple : Colors.blue),
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
                    obscureText: hide_password,
                    onEditingComplete: () {
                      setState(() {
                        password_check = false;
                      });
                      if (last_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(last_name);
                      } else if (mail_controller.text == "") {
                        FocusScope.of(context).requestFocus(mail);
                      } else if (mobile_number_controller.text == "") {
                        FocusScope.of(context).requestFocus(mobile_number);
                      } else if (first_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(password);
                      } else if (re_enter_password_controller.text == "") {
                        FocusScope.of(context).requestFocus(re_enter_password);
                      } else {
                        password.unfocus();
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
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
                    controller: re_enter_password_controller,
                    focusNode: re_enter_password,
                    obscureText: hide_re_entered_password,
                    onEditingComplete: () {
                      setState(() {
                        re_enter_password_check = false;
                      });
                      if (last_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(last_name);
                      } else if (mail_controller.text == "") {
                        FocusScope.of(context).requestFocus(mail);
                      } else if (mobile_number_controller.text == "") {
                        FocusScope.of(context).requestFocus(mobile_number);
                      } else if (password_controller.text == "") {
                        FocusScope.of(context).requestFocus(password);
                      } else if (first_name_controller.text == "") {
                        FocusScope.of(context).requestFocus(re_enter_password);
                      } else {
                        re_enter_password.unfocus();
                      }
                    },
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.key,
                          color: Colors.white), // Adjust prefix icon color
                      suffix: GestureDetector(
                        child: Icon(
                            hide_re_entered_password
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white), // Adjust suffix icon color
                        onTap: () {
                          setState(() {
                            if (hide_password) {
                              hide_re_entered_password = false;
                            } else {
                              hide_re_entered_password = true;
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
                  padding:
                      const EdgeInsets.only(top: 20, left: 100, right: 100),
                  child: ElevatedButton(
                    onPressed: () {
                      signup_click();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      shape: const StadiumBorder(),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Let's Start!",
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
