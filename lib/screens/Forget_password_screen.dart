// ignore_for_file: camel_case_types, file_names, non_constant_identifier_names, must_be_immutable, prefer_interpolation_to_compose_strings, avoid_print, unused_local_variable, use_build_context_synchronously

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:s_messages/screens/Forget_password_screen_2.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class Forgot_password_screen extends StatefulWidget {
  String user_id = "";
  String mobile_number = "";
  String mail = "";
  Forgot_password_screen(
      {super.key,
      required this.mobile_number,
      required this.user_id,
      required this.mail});

  @override
  State<StatefulWidget> createState() => _Forgot_password_screen();
}

class _Forgot_password_screen extends State<Forgot_password_screen> {
  final otp_controller = TextEditingController();
  final otp = FocusNode();
  bool otp_check = false;
  bool hide_password = true;
  String generated_otp = "";
  bool loading_screen = false;

  Future<void> _showInvalidOTPDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invalid OTP!'),
          content: const Text('Please check your OTP once.'),
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

  Future<void> _showUnableToSendDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error!'),
          content: const Text('Unable to send OTP on your Mail.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                'Ok',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> mailGenerate() async {
    generateVerificationCode();
    bool isGenerated = false;
    String username = 'gohelsneh21@gmail.com';
    String password = 'gtlb ofhq oerz ctus';

    final smtpServer = gmail(username, password);

    final currentTime = DateTime.now();
    String greeting = '';

    if (currentTime.hour < 12) {
      greeting = 'Good morning,';
    } else if (currentTime.hour < 18) {
      greeting = 'Good afternoon,';
    } else {
      greeting = 'Good evening,';
    }

    final message = Message()
      ..from = Address(username, 'S Message Team')
      ..recipients.add(widget.mail)
      ..subject = 'Verification Code'
      ..html = '''
      <html>

<body style="background-color: black; color: blue;">
    <center>
        <img src="photos/System/Full_S_Messages_logo_final.png" alt="Description of Image" width="200" height="250">

        <h1>Verification Code</h1>
        <p style="font-size: 24px; font-weight: bold; color: white;letter-spacing: 5px;">$generated_otp</p>
        <p style="font-size: 18px;">$greeting</p>
        <p style="font-size: 18px;">Use this code to verify your User ID.</p>
        <p style="font-size: 18px;">Please do not share this code with anyone for security reasons.</p>
        <p style="font-size: 18px;">Thank you for using our application. We appreciate your trust.</p>
        <p style="font-size: 18px;">Best regards,</p>
        <p style="font-size: 18px; color: white;">S Messgaes Team</p>
    </center>
</body>

</html>
    ''';

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      setState(() {
        loading_screen = false;
      });
    } catch (e) {
      var type = FeedbackType.warning;
      Vibrate.feedback(type);
      Navigator.pop(context);
      _showUnableToSendDialog();
      setState(() {
        loading_screen = false;
      });
      print('Error: $e');
    }
    return isGenerated;
  }

  void generateVerificationCode() {
    Random random = Random();
    int min = 100000;
    int max = 999999;
    int verificationCode = min + random.nextInt(max - min);

    setState(() {
      generated_otp = verificationCode.toString();
    });
  }

  void verify_click() {
    if (otp_controller.text != "") {
      if (otp_controller.text == generated_otp) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Forget_password_screen_2(
                user_id: widget.user_id,
              );
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
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
      } else {
        setState(() {
          otp_check = true;
        });
        var type = FeedbackType.warning;
        Vibrate.feedback(type);
        _showInvalidOTPDialog();
      }
    } else {
      setState(() {
        otp_check = true;
      });
      var type = FeedbackType.warning;
      Vibrate.feedback(type);
      _showInvalidOTPDialog();
    }
  }

  @override
  void initState() {
    super.initState();
    loading_screen = true;
    mailGenerate();
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
            height: screen_height,
            width: screen_width,
            decoration: const BoxDecoration(color: Colors.black),
            duration: const Duration(),
            child: ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Center(
                    child: GradientText(
                      "Forget Password?",
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                  child: Center(
                    child: Text(
                      "Don't worry we have send you a verification code on your mail.",
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
                  padding:
                      const EdgeInsets.only(top: 50, left: 100, right: 100),
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
