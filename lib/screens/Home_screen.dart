// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names, avoid_unnecessary_containers, must_be_immutable, avoid_print, deprecated_member_use, no_leading_underscores_for_local_identifiers, empty_catches

import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:qr_bar_code_scanner_dialog/qr_bar_code_scanner_dialog.dart';
import 'package:s_messages/screens/Chat_room_screen.dart';
import 'package:s_messages/screens/Setting_screen.dart';
import 'package:s_messages/screens/Status_screen.dart';
import 'package:s_messages/services/Chat_services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:s_messages/services/Status_services.dart';
// import 'package:s_messages/screens/OTP_notification.dart';

class Home_screen extends StatefulWidget {
  String user_id = "";
  Home_screen({Key? key, required this.user_id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _Home_screen();
}

class _Home_screen extends State<Home_screen> {
  late PageController page_controller;
  int current_index = 0;
  int current_page = 0;
  final mobile_number_controller = TextEditingController();
  final mobile_number = FocusNode();
  List<Map<String, dynamic>> chatInformation = [];
  bool none = false;
  List<bool> is_request_sent = [];
  List<bool> is_request_recive = [];
  int size = 0;
  bool loading_screen = false;
  bool show_qr = false;
  bool scan_qr = false;
  // late QRViewController controller;
  // final _qrBarCodeScannerDialogPlugin = QrBarCodeScannerDialog();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Map<dynamic, dynamic> imageUrl = {};
  bool chat_loading = true;
  Map<String, dynamic>? userData;
  Chat_services cs = Chat_services();
  List<int> order = [];
  bool fav_order = false;
  final note_controller = TextEditingController();
  final note = FocusNode();
  List<Map<String, dynamic>> statusData = [];
  bool status_loading = true;
  

  Future<void> _showRejectConfirmationDialog(int index) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject?'),
          content:
              const Text('Are your sure want to reject the friend request?'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  loading_screen = true;
                });

                try {
                  // Remove chat data from sender side
                  await FirebaseFirestore.instance
                      .collection(chatInformation[index]['user_id'])
                      .doc('Chat_information')
                      .update({
                    widget.user_id: FieldValue.delete(),
                  });

                  DocumentSnapshot docSnapshot = await FirebaseFirestore
                      .instance
                      .collection(chatInformation[index]['user_id'])
                      .doc("Chat_information")
                      .get();

                  if (docSnapshot.data() == null ||
                      (docSnapshot.data() as Map).isEmpty) {
                    print("not exist");
                    DocumentReference docRef = FirebaseFirestore.instance
                        .collection(chatInformation[index]['user_id'])
                        .doc("Chat_information");
                    await docRef.set({
                      'None': "None",
                    });
                  } else {
                    print("Exist");
                  }

                  // Remove chat data from receiver side
                  await FirebaseFirestore.instance
                      .collection(widget.user_id)
                      .doc('Chat_information')
                      .update({
                    chatInformation[index]['user_id']: FieldValue.delete(),
                  });

                  docSnapshot = await FirebaseFirestore.instance
                      .collection(widget.user_id)
                      .doc("Chat_information")
                      .get();

                  if (docSnapshot.data() == null ||
                      (docSnapshot.data() as Map).isEmpty) {
                    print("not exist");
                    DocumentReference docRef = FirebaseFirestore.instance
                        .collection(widget.user_id)
                        .doc("Chat_information");
                    await docRef.set({
                      'None': "None",
                    });
                  } else {
                    print("Exist");
                  }

                  check_for_chats();
                } catch (e) {
                  print('Failed to remove key-value pair: $e');
                } finally {
                  setState(() {
                    loading_screen = false;
                  });
                }
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

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

  Future<void> _showUserAlreadyExistInChatDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('User Already Exist!'),
          content: const Text('This user is already exist in your chat.'),
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

  Future<void> _showAddStatusFirstDialog() async {
    var type = FeedbackType.error;
    Vibrate.feedback(type);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Status not found'),
          content:
              const Text('Please add status before updating your notes...'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                'ok',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void getNoteModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final Size size = MediaQuery.of(context).size;
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: 500,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 38, 46, 56),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 40, left: 20),
                child: Text(
                  "Enter you note : ",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: TextField(
                  controller: note_controller,
                  focusNode: note,
                  maxLength: 20,
                  onEditingComplete: () {
                    note.unfocus();
                  },
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person,
                        color: Colors.white), // Adjust prefix icon color
                    suffix: GestureDetector(
                      child: const Icon(Icons.clear,
                          color: Colors.white), // Adjust suffix icon color
                      onTap: () {
                        note_controller.clear();
                      },
                    ),
                    filled: true,
                    fillColor: Colors.black,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    hintText: "note...",
                    hintStyle: const TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20),
                    // errorBorder: InputBorder.none,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white), // Set text color
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 50, horizontal: (size.width / 2 - 100)),
                child: ElevatedButton(
                  onPressed: () async {
                    if (note_controller.text.isNotEmpty) {
                      Navigator.pop(context);
                      await Status_services()
                          .updateNote(note_controller.text, widget.user_id);
                      setState(() {
                        status_loading = true;
                      });
                      await get_user_details();
                      setState(() {
                        status_loading = false;
                      });
                    } else {
                      note_controller.clear();
                      FocusScope.of(context).requestFocus(note);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shape: const StadiumBorder(),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Submit",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> check_for_chats() async {
    print(widget.user_id);
    setState(() {
      chatInformation.clear();
      is_request_recive.clear();
      is_request_sent.clear();
      order.clear();
      statusData.clear();
    });

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection(widget.user_id)
          .doc("Chat_information")
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;

        if (data.containsKey("None")) {
          print("No chats are there");
          setState(() {
            none = true;
            loading_screen = false;
          });
        } else {
          print("Chat exists.");
          data.forEach((key, value) {
            if (value == "Request sent") {
              setState(() {
                is_request_sent.add(true);
                is_request_recive.add(false);
                chatInformation.add({});
              });
            } else if (value == "Request recived") {
              setState(() {
                is_request_sent.add(false);
                is_request_recive.add(true);
                chatInformation.add({key: value});
              });
            } else {
              setState(() {
                is_request_sent.add(false);
                is_request_recive.add(false);
                chatInformation.add({key: value});
              });
            }
          });
          get_chat_data();
          setState(() {
            none = false;
          });
        }
      } else {
        // Handle the case when the document does not exist
        setState(() {
          loading_screen = false;
        });
      }
    } catch (e) {
      print("Failed to fetch data: $e");
      loading_screen = false;
    }
  }

  Future<void> get_chat_data() async {
    setState(() {
      loading_screen = true;
      chat_loading = true;
    });

    List<Future<void>> futures = []; // List to hold all futures
    int length = chatInformation.length;
    for (int index = 0; index < length; index++) {
      chatInformation[index].forEach((key, value) {
        if (is_request_recive[index] == true) {
          futures.add(_fetchAndUpdateRequestReciveChatData(index, key));
        } else if (is_request_sent[index] == false &&
            is_request_recive[index] == false) {
          futures.add(_fetchAndUpdateChatData(index, key, value));
        }
      });
    }

    // Wait for all futures to complete
    await Future.wait(futures);

    setOrder();

    setState(() {
      loading_screen = false;
      chat_loading = false;
    });

    get_status_data();
  }

  // getting request revice chat data

  Future<void> _fetchAndUpdateRequestReciveChatData(
      int index, String key) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection(key)
          .doc("User_information")
          .get();
      var data = docSnapshot.data() as Map<String, dynamic>;

      chatInformation[index] = data;
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child(chatInformation[index]['profile_pic']);
      final url = await ref.getDownloadURL();

      // print(chatInformation);

      setState(() {
        imageUrl[index] = url;
      });
    } catch (e) {
      print("Cannot fetch request data...\nGetting exception : $e");
    }
  }

  // getting all active chat data

  Future<void> _fetchAndUpdateChatData(
      int index, String key, String value) async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection(key)
          .doc("User_information")
          .get();
      var data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        chatInformation[index] = data;
      });
      final storage = FirebaseStorage.instance;
      final ref = storage.ref().child(chatInformation[index]['profile_pic']);
      final url = await ref.getDownloadURL();

      setState(() {
        imageUrl[index] = url;
      });

      if (chatInformation[index]['status'] == 'Yes') {
        setState(() {
          statusData.add({
            'user_id': chatInformation[index]['user_id'],
            'index': index,
          });
        });
      }

      docSnapshot = await FirebaseFirestore.instance
          .collection('Chat_rooms')
          .doc(value)
          .get();
      data = docSnapshot.data() as Map<String, dynamic>;

      setState(() {
        chatInformation[index].addAll(data);
        chatInformation[index].addAll({'chat_id': value});
      });

      // print(chatInformation);
    } catch (e) {
      print("Cannot fetch active chat data...\nGetting exception : $e");
    }
  }

  void setOrder() {
    List<int> favIndices = [];
    List<int> requestIndices = [];
    List<int> newMessageIndices = [];
    List<int> normalChatIndices = [];

    for (int i = 0; i < is_request_recive.length; i++) {
      if (fav_order == true &&
          chatInformation[i]['${chatInformation[i]['user_id']}_fav'] == "Yes") {
        favIndices.add(i);
      } else if (is_request_recive[i]) {
        requestIndices.add(i);
      } else if (chatInformation[i][widget.user_id] == "Yes") {
        newMessageIndices.add(i);
      } else {
        normalChatIndices.add(i);
      }
    }

    // Combine the indices in the specified order
    order.addAll(favIndices);
    order.addAll(requestIndices);
    order.addAll(newMessageIndices);
    order.addAll(normalChatIndices);

    // Print or return the order list
    print(order);
  }

  void qr_pressed() {
    setState(() {
      show_qr = true;
    });
  }

  void scan_user_pressed() {
    setState(() {
      scan_qr = true;
    });
    // _scanQRCode(context);
  }

  // void _scanQRCode(BuildContext context) {
  //   _qrBarCodeScannerDialogPlugin.getScannedQrBarCode(
  //     context: context,
  //     onCode: (code) {
  //       setState(() {
  //         scan_qr = false;
  //       });
  //       // Call the function after getting the code
  //       _handleScannedCode(code!);
  //     },
  //   );
  // }

  Future<void> get_status_data() async {
    setState(() {
      status_loading = true;
    });
    for (int index = 0; index < statusData.length; index++) {
      try {
        DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
            .collection('Status')
            .doc(statusData[index]['user_id'])
            .get();
        var data = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          statusData[index].addAll(data);
        });
      } catch (e) {
        print("Unable to get status data.\nGetting exception : $e");
      }
    }
    setState(() {
      status_loading = false;
    });
  }

  Future<void> get_user_status_data() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Status')
          .doc(widget.user_id)
          .get();
      var data = docSnapshot.data() as Map<String, dynamic>;
      setState(() {
        userData!.addAll(data);
      });
    } catch (e) {
      print("Unable to get status data.\nGetting exception : $e");
    }
  }

  Future<void> update_status() async {
    try {
      final ImagePicker image_picker = ImagePicker();
      var get_image = await image_picker.pickImage(
        source: ImageSource.gallery,
      );
      File? image = File(get_image!.path);
      await Status_services.addStatus(widget.user_id, image);
      setState(() {
        status_loading = true;
      });
      await get_user_details();
      setState(() {
        status_loading = false;
      });
    } catch (e) {}
  }

  Future<void> _handleScannedCode(String result) async {
    bool user_check = false;
    // try {
    //   controller.scannedDataStream.listen(
    //     (scanData) async {
    //       setState(() {
    //         result = scanData.code!;
    //       });
    //       controller.pauseCamera();

    //       controller.resumeCamera();
    //     },
    //   );
    // } catch (e) {
    //   print("Error to scan the qr : $e");
    // }
    List<Map<String, dynamic>> userInformation = [];
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
        data.forEach((key, value) async {
          if (result == value) {
            user_check = true;
            // to make changes at sender side.
            try {
              DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
                  .collection(widget.user_id)
                  .doc("Chat_information")
                  .get();

              if (docSnapshot.exists) {
                Map<String, dynamic> data =
                    docSnapshot.data() as Map<String, dynamic>;
                // if no chats are there at sender side
                if (data.containsKey("None")) {
                  final CollectionReference users =
                      FirebaseFirestore.instance.collection(widget.user_id);
                  final DocumentReference docRef =
                      users.doc("Chat_information");
                  await docRef.set({
                    result: 'Request sent',
                  });
                  // otp_notification.sendNotification("New Friend Added", "Request of your account has been sent. Please wait for their responce.");
                } else {
                  final CollectionReference collection =
                      FirebaseFirestore.instance.collection(widget.user_id);
                  final DocumentReference docRef =
                      collection.doc('Chat_information');

                  try {
                    DocumentSnapshot snapshot = await docRef.get();
                    if (snapshot.exists) {
                      Map<String, dynamic> data =
                          snapshot.data() as Map<String, dynamic>;
                      if (data.containsKey(result)) {
                        _showUserAlreadyExistInChatDialog();
                      } else {
                        await docRef.update({result: "Request sent"});
                      }
                    }
                  } catch (e) {
                    print('Error adding field to document: $e');
                  }
                }
              }
            } catch (e) {
              print("Failed to fetch data: $e");
            }
            // to make changes on reciver side.....
            try {
              DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
                  .collection(result)
                  .doc("Chat_information")
                  .get();

              if (docSnapshot.exists) {
                Map<String, dynamic> data =
                    docSnapshot.data() as Map<String, dynamic>;

                if (data.containsKey("None")) {
                  final CollectionReference users =
                      FirebaseFirestore.instance.collection(result);
                  final DocumentReference docRef =
                      users.doc("Chat_information");
                  await docRef.set({
                    widget.user_id: 'Request recived',
                  });
                } else {
                  final CollectionReference collection =
                      FirebaseFirestore.instance.collection(result);
                  final DocumentReference docRef =
                      collection.doc('Chat_information');

                  try {
                    DocumentSnapshot snapshot = await docRef.get();
                    if (snapshot.exists) {
                      Map<String, dynamic> data =
                          snapshot.data() as Map<String, dynamic>;
                      if (data.containsKey(widget.user_id)) {
                        _showUserAlreadyExistInChatDialog();
                      } else {
                        await docRef
                            .update({widget.user_id: "Request recived"});
                      }
                    }
                  } catch (e) {
                    print('Error adding field to document: $e');
                  }
                }
              }
            } catch (e) {
              print("Failed to fetch data: $e");
            }
          }
        });
        if (user_check == false) {
          setState(() {
            var type = FeedbackType.warning;
            Vibrate.feedback(type);
            _showInvalidUseridDialog();
          });
        }
      }
    } catch (e) {
      setState(() {
        loading_screen = false;
      });
      print("Failed to fetch data: $e");
    }
  }

  Future<void> get_user_details() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection(widget.user_id)
          .doc('User_information')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        setState(() {
          userData = docSnapshot.data() as Map<String, dynamic>;
        });

        final storage = FirebaseStorage.instance;
        final ref = storage.ref().child(userData!['profile_pic']);
        final url = await ref.getDownloadURL();

        setState(() {
          imageUrl['user_img'] = url;
        });

        if (userData!['status'] == 'Yes') {
          bool result =
              await Status_services().autoUpdateStatusAndNotes(widget.user_id);
          if (result) {
            get_user_details();
          }
          await get_user_status_data();
        }
      } else {
        print("Document does not exist or has no data.");
      }
    } catch (e) {
      print("Getting exeption : $e");
    }
  }

  Future<void> request_accepted(int index) async {
    String chat_id =
        "${userData!['mobile_number']}||${chatInformation[index]['mobile_number']}";

    try {
      // update chat_information at receiver side.
      await FirebaseFirestore.instance
          .collection(widget.user_id)
          .doc('Chat_information')
          .update({
        chatInformation[index]['user_id']: chat_id,
      });

      // update chat_information at sender side.
      await FirebaseFirestore.instance
          .collection(chatInformation[index]['user_id'])
          .doc('Chat_information')
          .update({
        widget.user_id: chat_id,
      });

      // creating notification fields...

      await FirebaseFirestore.instance
          .collection('Chat_rooms')
          .doc(chat_id)
          .set({
        widget.user_id: 'No',
        chatInformation[index]['user_id']: 'No',
        "${widget.user_id}_timestamp": "None",
        "${chatInformation[index]['user_id']}_timestamp": "No",
        "${widget.user_id}_fav": "None",
        "${chatInformation[index]['user_id']}_fav": "No",
      });

      // creating new chat section.
      cs.sendMessage(widget.user_id, chatInformation[index]['user_id'],
          "Hello 👋👋", chat_id,userData!['user_name'],"friend_request",chatInformation[index]['fcm']);

      check_for_chats();
    } catch (e) {
      setState(() {
        loading_screen = false;
      });

      SnackBar(
        content: Text("Error adding data to Firestore: $e"),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loading_screen = true;
    page_controller = PageController(initialPage: current_page);
    get_user_details();
    check_for_chats();
  }

  @override
  void dispose() {
    page_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screen_height = screenSize.height;
    double screen_width = screenSize.width;
    Future<bool> _onWillPop() async {
      if (show_qr == true) {
        setState(() {
          show_qr == false;
        });
        return false;
      } else if (scan_qr == true) {
        setState(() {
          scan_qr = false;
        });
        return false;
      }
      return true;
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(current_page == 0
              ? "S Messages"
              : current_page == 1
                  ? "Status"
                  : current_page == 2
                      ? "Quick Add"
                      : "Calls"),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          actions: [
            const IconButton(
              onPressed: null,
              icon: Icon(
                Icons.camera_alt,
                color: Colors.white,
              ),
            ),
            const IconButton(
              onPressed: null,
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            PopupMenuButton(
              offset: const Offset(0, 48),
              color: const Color.fromRGBO(30, 25, 38, 1.0),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'Favorite_chats',
                    child: Text(
                      'Favorite chats',
                      style: TextStyle(
                          color: fav_order ? Colors.blue : Colors.white),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Settings',
                    child: Text(
                      'Settings',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ];
              },
              onSelected: (value) {
                if (value == "Settings") {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          Setting_screen(
                        user_id: widget.user_id,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(1.0, 0.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                } else if (value == "Favorite_chats") {
                  setState(() {
                    fav_order = !fav_order;
                  });
                  check_for_chats();
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            PageView(
              controller: page_controller,
              onPageChanged: (int page) {
                setState(() {
                  current_page = page;
                });
              },
              children: [
                AnimatedContainer(
                  height: screen_height,
                  width: screen_width,
                  decoration: const BoxDecoration(color: Colors.black),
                  duration: const Duration(),
                  child: none
                      ? RefreshIndicator(
                          onRefresh: check_for_chats,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Container(
                                    child: const Text(
                                      "Ready to make connections?",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    child: const Text(
                                      "Invite friends and dive into lively chats!",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: check_for_chats,
                          child: chat_loading
                              ? const Center(
                                  child: Text(
                                    "Loading chats...",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: chatInformation.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
                                      child: chat_loading
                                          ? const Center()
                                          : is_request_recive[index]
                                              ? ListTile(
                                                  leading: Stack(
                                                    children: [
                                                      Container(
                                                        width:
                                                            50, // Adjust the width of the container
                                                        height:
                                                            50, // Adjust the height of the container
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors
                                                                .blue, // Set the color of the ring
                                                            width:
                                                                2, // Set the width of the ring
                                                          ),
                                                        ),
                                                        child: ClipOval(
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: imageUrl[
                                                                order[index]],
                                                            placeholder:
                                                                (context,
                                                                        url) =>
                                                                    const Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 70),
                                                              ],
                                                            ),
                                                            errorWidget: (context,
                                                                    url,
                                                                    error) =>
                                                                const Icon(Icons
                                                                    .error),
                                                            imageBuilder: (context,
                                                                    imageProvider) =>
                                                                Container(
                                                              width: 150.0,
                                                              height: 150.0,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image:
                                                                    DecorationImage(
                                                                  image:
                                                                      imageProvider,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize: MainAxisSize
                                                        .min, // Ensure the row takes minimum space
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          _showRejectConfirmationDialog(
                                                              index);
                                                        },
                                                        icon: const Icon(
                                                          Icons.cancel,
                                                          color: Colors.red,
                                                          size: 35,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          request_accepted(
                                                              index);
                                                        },
                                                        icon: const Icon(
                                                          Icons.check_circle,
                                                          color: Colors.green,
                                                          size: 35,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  title: Text(
                                                    chatInformation[
                                                            order[index]]
                                                        ['user_name'],
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  subtitle: const Text(
                                                    "Friend Request...",
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                )
                                              : is_request_sent[index]
                                                  ? const Center()
                                                  : Material(
                                                      color: Colors.black,
                                                      child: ListTile(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            PageRouteBuilder(
                                                              pageBuilder: (context, animation, secondaryAnimation) => Chat_room_screen(
                                                                  widget
                                                                      .user_id,
                                                                  chatInformation[
                                                                          order[
                                                                              index]]
                                                                      [
                                                                      'user_id'],
                                                                  chatInformation[
                                                                          order[
                                                                              index]]
                                                                      [
                                                                      'user_name'],
                                                                  chatInformation[
                                                                          order[
                                                                              index]]
                                                                      [
                                                                      'chat_id'],
                                                                  imageUrl[order[
                                                                      index]],userData!['user_name'],chatInformation[
                                                                          order[
                                                                              index]]
                                                                      [
                                                                      'fcm']),
                                                              transitionsBuilder:
                                                                  (context,
                                                                      animation,
                                                                      secondaryAnimation,
                                                                      child) {
                                                                var begin =
                                                                    const Offset(
                                                                        1.0,
                                                                        0.0);
                                                                var end =
                                                                    Offset.zero;
                                                                var curve =
                                                                    Curves.ease;

                                                                var tween = Tween(
                                                                        begin:
                                                                            begin,
                                                                        end:
                                                                            end)
                                                                    .chain(CurveTween(
                                                                        curve:
                                                                            curve));

                                                                return SlideTransition(
                                                                  position: animation
                                                                      .drive(
                                                                          tween),
                                                                  child: child,
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        splashColor: const Color
                                                            .fromARGB(
                                                            90, 255, 255, 255),
                                                        leading: Stack(
                                                          children: [
                                                            Container(
                                                              width:
                                                                  50, // Adjust the width of the container
                                                              height:
                                                                  50, // Adjust the height of the container
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .blue, // Set the color of the ring
                                                                  width:
                                                                      2, // Set the width of the ring
                                                                ),
                                                              ),
                                                              child: ClipOval(
                                                                child:
                                                                    CachedNetworkImage(
                                                                  imageUrl:
                                                                      imageUrl[
                                                                          order[
                                                                              index]],
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .person,
                                                                          size:
                                                                              70),
                                                                    ],
                                                                  ),
                                                                  errorWidget: (context,
                                                                          url,
                                                                          error) =>
                                                                      const Icon(
                                                                          Icons
                                                                              .error),
                                                                  imageBuilder:
                                                                      (context,
                                                                              imageProvider) =>
                                                                          Container(
                                                                    width:
                                                                        150.0,
                                                                    height:
                                                                        150.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Positioned(
                                                              right: 0,
                                                              bottom: 0,
                                                              child: chatInformation[
                                                                              order[index]]
                                                                          [
                                                                          'status'] ==
                                                                      'Yes'
                                                                  ? Container(
                                                                      width:
                                                                          14, // Adjust the width of the ring
                                                                      height:
                                                                          14, // Adjust the height of the ring
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color: Colors
                                                                            .blue, // Set the color of the ring
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.white, // Set the color of the border
                                                                          width:
                                                                              2, // Set the width of the border
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : const Center(),
                                                            ),
                                                          ],
                                                        ),
                                                        trailing:
                                                            is_request_recive[
                                                                    index]
                                                                ? const Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min, // Ensure the row takes minimum space
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed:
                                                                            null,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .cancel,
                                                                          color:
                                                                              Colors.red,
                                                                          size:
                                                                              35,
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        onPressed:
                                                                            null,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .check_circle,
                                                                          color:
                                                                              Colors.green,
                                                                          size:
                                                                              35,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Row(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min, // Ensure the row takes minimum space
                                                                    children: [
                                                                      IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          try {
                                                                            if (chatInformation[order[index]]['${chatInformation[order[index]]['user_id']}_fav'] ==
                                                                                "No") {
                                                                              await FirebaseFirestore.instance.collection('Chat_rooms').doc(chatInformation[order[index]]['chat_id']).update({
                                                                                '${chatInformation[order[index]]['user_id']}_fav': 'Yes'
                                                                              });
                                                                              Fluttertoast.showToast(
                                                                                msg: "Chat added to your favourite",
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                gravity: ToastGravity.BOTTOM,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.blue.shade100,
                                                                                textColor: Colors.black,
                                                                                fontSize: 16.0,
                                                                              );
                                                                            } else {
                                                                              await FirebaseFirestore.instance.collection('Chat_rooms').doc(chatInformation[order[index]]['chat_id']).update({
                                                                                '${chatInformation[order[index]]['user_id']}_fav': 'No'
                                                                              });
                                                                              Fluttertoast.showToast(
                                                                                msg: "Chat removed from your favourite",
                                                                                toastLength: Toast.LENGTH_SHORT,
                                                                                gravity: ToastGravity.BOTTOM,
                                                                                timeInSecForIosWeb: 1,
                                                                                backgroundColor: Colors.blue.shade100,
                                                                                textColor: Colors.black,
                                                                                fontSize: 16.0,
                                                                              );
                                                                            }
                                                                          } catch (e) {
                                                                            print("Getting error while updating favourite. Getting exception : $e");
                                                                          } finally {
                                                                            check_for_chats();
                                                                          }
                                                                        },
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .favorite,
                                                                          color: chatInformation[order[index]]['${chatInformation[order[index]]['user_id']}_fav'] == "Yes"
                                                                              ? Colors.pink
                                                                              : Colors.blue.shade50,
                                                                        ),
                                                                      ),
                                                                      const IconButton(
                                                                        onPressed:
                                                                            null,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .call,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                      const IconButton(
                                                                        onPressed:
                                                                            null,
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .videocam,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                        title: Text(
                                                          chatInformation[
                                                                  order[index]]
                                                              ['user_name'],
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                        subtitle: Text(
                                                          chatInformation[order[
                                                                          index]]
                                                                      [widget
                                                                          .user_id] ==
                                                                  "Yes"
                                                              ? "New messages..."
                                                              : chatInformation[
                                                                      order[
                                                                          index]]
                                                                  ['about'],
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.blue,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                    );
                                  },
                                ),
                        ),
                ),
                AnimatedContainer(
                  decoration: const BoxDecoration(color: Colors.black),
                  duration: const Duration(),
                  child: status_loading
                      ? const Center(
                          child: Text(
                            "Loading status...",
                            style: TextStyle(color: Colors.blue),
                          ),
                        )
                      : ListView.builder(
                          itemCount: statusData.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 20, left: screen_width % 25),
                                    child: const Text(
                                      "My Status",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Material(
                                      color: Colors.black,
                                      child: ListTile(
                                        leading: Stack(
                                          children: [
                                            Container(
                                              width:
                                                  50, // Adjust the width of the container
                                              height:
                                                  50, // Adjust the height of the container
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors
                                                      .blue, // Set the color of the ring
                                                  width:
                                                      2, // Set the width of the ring
                                                ),
                                              ),
                                              child: ClipOval(
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      imageUrl['user_img'],
                                                  placeholder: (context, url) =>
                                                      const Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Icon(Icons.person,
                                                          size: 70),
                                                    ],
                                                  ),
                                                  errorWidget: (context, url,
                                                          error) =>
                                                      const Icon(Icons.error),
                                                  imageBuilder: (context,
                                                          imageProvider) =>
                                                      Container(
                                                    width: 150.0,
                                                    height: 150.0,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 5),
                                              child: FloatingActionButton.small(
                                                heroTag:
                                                    'editButton_${widget.user_id}', // Unique heroTag for this button
                                                onPressed: () {
                                                  if (userData!['status'] ==
                                                      'Yes') {
                                                    note_controller.text =
                                                        userData!['note'];
                                                    getNoteModalBottomSheet(
                                                        context);
                                                  } else {
                                                    _showAddStatusFirstDialog();
                                                  }
                                                },
                                                child: const Icon(Icons.edit),
                                              ),
                                            ),
                                            FloatingActionButton.small(
                                              heroTag:
                                                  'addButton_${widget.user_id}', // Unique heroTag for this button
                                              onPressed: () {
                                                update_status();
                                              },
                                              child: const Icon(Icons.add),
                                            ),
                                          ],
                                        ),
                                        title: Text(
                                          userData!['user_name'],
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          userData!['status'] == "Yes"
                                              ? (userData!['note'] ==
                                                          'New moments...' &&
                                                      userData!['note_timestamp']
                                                              .toString() ==
                                                          "None")
                                                  ? "Add your note..."
                                                  : userData!['note']
                                              : "Add your note...",
                                          style: const TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        splashColor: const Color.fromARGB(
                                            90, 255, 255, 255),
                                        onTap: () {
                                          if (userData!['status'] == 'Yes') {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    Status_screen(
                                                        widget.user_id,
                                                        '',
                                                        userData!['user_name'],
                                                        '',
                                                        imageUrl['user_img'],
                                                        userData![
                                                            'status_image'],userData!['user_name'],""),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  return FadeTransition(
                                                      opacity: animation,
                                                      child: child);
                                                },
                                              ),
                                            );
                                          } else {
                                            update_status();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: screen_width % 25,
                                        top: 10,
                                        bottom: 10),
                                    child: const Text(
                                      "Your friends moments...",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Material(
                                  color: Colors.black,
                                  child: ListTile(
                                    leading: Container(
                                      width:
                                          50, // Adjust the width of the container
                                      height:
                                          50, // Adjust the height of the container
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors
                                              .blue, // Set the color of the ring
                                          width: 2, // Set the width of the ring
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: imageUrl[
                                              statusData[index - 1]['index']],
                                          placeholder: (context, url) =>
                                              const Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Icon(Icons.person, size: 70),
                                            ],
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                          imageBuilder:
                                              (context, imageProvider) =>
                                                  Container(
                                            width: 150.0,
                                            height: 150.0,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    trailing: const Row(
                                      mainAxisSize: MainAxisSize
                                          .min, // Ensure the row takes minimum space
                                      children: [
                                        IconButton(
                                          onPressed: null,
                                          icon: Icon(
                                            Icons.favorite,
                                            color: Colors.pink,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: null,
                                          icon: Icon(
                                            Icons.add_reaction_outlined,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      chatInformation[statusData[index - 1]
                                          ['index']]['user_name'],
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      statusData[index - 1]['note'],
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
                                    ),
                                    splashColor:
                                        const Color.fromARGB(90, 255, 255, 255),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              Status_screen(
                                                  widget.user_id,
                                                  chatInformation[
                                                      statusData[index - 1]
                                                          ['index']]['user_id'],
                                                  chatInformation[statusData[index - 1]['index']]
                                                      ['user_name'],
                                                  chatInformation[
                                                      statusData[index - 1]
                                                          ['index']]['chat_id'],
                                                  imageUrl[statusData[index - 1]
                                                      ['index']],
                                                  statusData[index - 1]
                                                      ['status_image'],userData!['user_name'],chatInformation[
                                                      statusData[index - 1]
                                                          ['index']]['fcm']),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return FadeTransition(
                                                opacity: animation,
                                                child: child);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                ),
                Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                        child: ListView(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 50),
                              child: Text(
                                "Link up, Chat on!",
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 30),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.transparent),
                                    width: screen_width / 2,
                                    child: const Center(
                                      child: Text(
                                        "Scan",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 25),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.transparent),
                                    width: screen_width / 2,
                                    child: const Center(
                                      child: Text(
                                        "QR Code",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 25),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.transparent),
                                    width: (screen_width / 2),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        width: (screen_width / 2) - 50,
                                        height: (screen_width / 2) - 50,
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () {
                                              scan_user_pressed();
                                            },
                                            icon: const Icon(
                                              Icons.qr_code_scanner,
                                              color: Colors.blue,
                                            ),
                                            iconSize: 45,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.transparent),
                                    width: (screen_width / 2),
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        width: (screen_width / 2) - 50,
                                        height: (screen_width / 2) - 50,
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () {
                                              qr_pressed();
                                            },
                                            icon: const Icon(
                                              Icons.qr_code,
                                              color: Colors.blue,
                                            ),
                                            iconSize: 45,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.transparent),
                                child: const Center(
                                  child: Text(
                                    "Use Mobile Number",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 25),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 30, left: 40, right: 40),
                              child: TextField(
                                controller: mobile_number_controller,
                                focusNode: mobile_number,
                                onEditingComplete: () {
                                  mobile_number.unfocus();
                                },
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.call,
                                      color: Colors
                                          .white), // Adjust prefix icon color
                                  suffix: GestureDetector(
                                    child: const Icon(Icons.clear,
                                        color: Colors
                                            .white), // Adjust suffix icon color
                                    onTap: () {
                                      mobile_number_controller.clear();
                                    },
                                  ),
                                  filled: true,
                                  fillColor: Colors.black,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  hintText: "Mobile Number",
                                  hintStyle: const TextStyle(
                                      color:
                                          Colors.white), // Set hint text color
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                      horizontal: 20), // Adjust content padding
                                  // errorBorder: InputBorder.none,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: const BorderSide(
                                        color:
                                            Colors.white), // Set border color
                                  ),
                                ),
                                style: const TextStyle(
                                    color: Colors.white), // Set text color
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    show_qr
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                show_qr = false;
                              });
                            },
                            child: AnimatedContainer(
                              height: screen_height,
                              width: screen_width,
                              duration: const Duration(milliseconds: 300),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(126, 0, 0, 0),
                              ),
                              child: Center(
                                child: Container(
                                  height: screen_width - 100,
                                  width: screen_width - 100,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: QrImageView(
                                    data: widget.user_id,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : scan_qr
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    scan_qr = false;
                                  });
                                },
                                child: AnimatedContainer(
                                  height: screen_height,
                                  width: screen_width,
                                  duration: const Duration(milliseconds: 300),
                                  decoration: const BoxDecoration(
                                    color: Color.fromARGB(126, 0, 0, 0),
                                  ),
                                  child: Center(
                                    child: Container(
                                      height: screen_width - 100,
                                      width: screen_width - 100,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      // child: QRView(
                                      //   key: qrKey,
                                      //   onQRViewCreated: _onQRViewCreated,
                                      // ),
                                      // child: _qrBarCodeScannerDialogPlugin
                                      //     .getScannedQrBarCode(
                                      //         context: context,
                                      //         onCode: (code) {
                                      //           setState(() {
                                      //             this.code = code;
                                      //           });
                                      //         }),
                                    ),
                                  ),
                                ),
                              )
                            : const Center()
                  ],
                ),
                AnimatedContainer(
                  duration: const Duration(),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: ListView.builder(
                    itemCount: 15,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: ListTile(
                          leading: Container(
                            width: 50, // Adjust the width of the container
                            height: 50, // Adjust the height of the container
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.blue, // Set the color of the ring
                                width: 2, // Set the width of the ring
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                "photos/profile_pic.png",
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          trailing: const Row(
                            mainAxisSize: MainAxisSize
                                .min, // Ensure the row takes minimum space
                            children: [
                              IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.favorite,
                                  color: Colors.pink,
                                ),
                              ),
                              // IconButton(
                              //   onPressed: null,
                              //   icon: Icon(
                              //     Icons.phone_callback_rounded,
                              //     color: Colors.white,
                              //   ),
                              // ),
                              // IconButton(
                              //   onPressed: null,
                              //   icon: Icon(
                              //     Icons.phone_forwarded,
                              //     color: Colors.white,
                              //   ),
                              // ),
                              IconButton(
                                onPressed: null,
                                icon: Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            "Person ${index + 1}",
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: const Text(
                            "17/04/2024 (Incoming)",
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
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
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.black),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            child: GNav(
              haptic: true,
              backgroundColor: Colors.black,
              color: Colors.white,
              activeColor: const Color.fromARGB(255, 124, 187, 237),
              tabBackgroundColor: Colors.grey.shade900,
              gap: 8,
              padding: const EdgeInsets.all(15),
              selectedIndex: current_page,
              onTabChange: (index) {
                setState(() {
                  current_index = index;
                });
                page_controller.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              tabs: const [
                GButton(
                  icon: Icons.chat,
                  text: "Chats",
                ),
                GButton(
                  icon: Icons.api,
                  text: "Status",
                ),
                GButton(
                  icon: Icons.add_reaction,
                  text: "Quick Add",
                ),
                GButton(
                  icon: Icons.call,
                  text: "Calls",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
