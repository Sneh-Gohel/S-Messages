// ignore_for_file: camel_case_types, file_names, non_constant_identifier_names, must_be_immutable, unused_import, use_build_context_synchronously, prefer_typing_uninitialized_variables, unused_local_variable, avoid_print, prefer_interpolation_to_compose_strings, empty_catches, avoid_unnecessary_containers

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:s_messages/screens/Login_screen.dart';
import 'package:image_picker/image_picker.dart';

class Setting_screen extends StatefulWidget {
  String user_id = "";
  Setting_screen({super.key, required this.user_id});

  @override
  State<StatefulWidget> createState() => _Setting_screen();
}

class _Setting_screen extends State<Setting_screen> {
  bool loading_screen = false;
  late String imageUrl;
  final storage = FirebaseStorage.instance;
  bool loading = true;
  bool error = false;
  Map<String, dynamic>? userData;
  final user_name_controller = TextEditingController();
  final user_name = FocusNode();
  final about_controller = TextEditingController();
  final about = FocusNode();
  final ImagePicker image_picker = ImagePicker();
  File? image;

  Future<void> _showUnableToUploadImageDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error!'),
          content: const Text(
              'Cannot able to update your profile picture. Please check your internet connection and try again!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                'ok!',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUnableToUpdateUsernameDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error!'),
          content: const Text(
              'Cannot able to update your Username. Please check your internet connection and try again!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                'ok!',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUnableToUpdateAboutDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error!'),
          content: const Text(
              'Cannot able to update your about. Please check your internet connection and try again!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text(
                'ok!',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void getUsernameModalBottomSheet(BuildContext context) {
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
                  "Enter Username : ",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: TextField(
                  controller: user_name_controller,
                  focusNode: user_name,
                  maxLength: 15,
                  onEditingComplete: () {
                    user_name.unfocus();
                  },
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person,
                        color: Colors.white), // Adjust prefix icon color
                    suffix: GestureDetector(
                      child: const Icon(Icons.clear,
                          color: Colors.white), // Adjust suffix icon color
                      onTap: () {
                        user_name_controller.clear();
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
                    hintText: "Username",
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
                  onPressed: () {
                    chage_user_name();
                    Navigator.pop(context);
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

  void getAboutModalBottomSheet(BuildContext context) {
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
                  "Enter about : ",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
                child: TextField(
                  controller: about_controller,
                  focusNode: about,
                  maxLength: 15,
                  onEditingComplete: () {
                    about.unfocus();
                  },
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.info,
                        color: Colors.white), // Adjust prefix icon color
                    suffix: GestureDetector(
                      child: const Icon(Icons.clear,
                          color: Colors.white), // Adjust suffix icon color
                      onTap: () {
                        about_controller.clear();
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
                    hintText: "About",
                    hintStyle: const TextStyle(
                        color: Colors.white), // Set hint text color
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 20), // Adjust content padding
                    // errorBorder: InputBorder.none,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                      borderSide: const BorderSide(
                          color: Colors.white), // Set border color
                    ),
                  ),
                  style: const TextStyle(color: Colors.white), // Set text color
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 50, horizontal: (size.width / 2 - 100)),
                child: ElevatedButton(
                  onPressed: () {
                    chage_about();
                    Navigator.pop(context);
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

  Future<void> _showlogoutDialog() async {
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
                logout();
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
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

  Future<void> chage_user_name() async {
    setState(() {
      loading_screen = true;
    });
    try {
      final CollectionReference users =
          FirebaseFirestore.instance.collection(widget.user_id);
      final DocumentReference docRef = users.doc("User_information");
      await docRef.set({
        'about': userData!['about'],
        'first_name': userData!['first_name'],
        'last_name': userData!['last_name'],
        'mail': userData!['mail'],
        'mobile_number': userData!['mobile_number'],
        'password': userData!['password'],
        'profile_pic': userData!['profile_pic'],
        'user_name': user_name_controller.text,
        'status': userData!['status'],
        'user_id': userData!['user_id']
      });
      get_user_details();
    } catch (e) {
      print("Cannot update user_name! getting exception : " + e.toString());
      _showUnableToUpdateUsernameDialog();
    } finally {
      setState(() {
        loading_screen = false;
      });
    }
  }

  Future<void> chage_about() async {
    setState(() {
      loading_screen = true;
    });
    try {
      final CollectionReference users =
          FirebaseFirestore.instance.collection(widget.user_id);
      final DocumentReference docRef = users.doc("User_information");
      await docRef.set({
        'about': about_controller.text,
        'first_name': userData!['first_name'],
        'last_name': userData!['last_name'],
        'mail': userData!['mail'],
        'mobile_number': userData!['mobile_number'],
        'password': userData!['password'],
        'profile_pic': userData!['profile_pic'],
        'user_name': userData!['user_name'],
        'status': userData!['status'],
        'user_id': userData!['user_id']
      });
      get_user_details();
    } catch (e) {
      print("Cannot update about! getting exception : " + e.toString());
      _showUnableToUpdateAboutDialog();
    } finally {
      setState(() {
        loading_screen = false;
      });
    }
  }

  void logout() async {
    try {
      var status;
      PermissionStatus storagePermissionStatus =
          await Permission.storage.status;
      if (storagePermissionStatus.isDenied) {
        status = await Permission.storage.request();
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/user_id.txt');
        await file.delete();
        print("File has been deleted.");
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/user_id.txt');
        await file.delete();
        print("File has been deleted.");
      }
    } catch (e) {}
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Login_screen(),
        ),
        (route) => false);
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
        getImageUrl();
      } else {
        print("Document does not exist or has no data.");
      }
    } catch (e) {
      print("Getting exeption : " + e.toString());
    }
  }

  Future<void> getImageUrl() async {
    try {
      final ref = storage.ref().child(userData!['profile_pic']);
      final url = await ref.getDownloadURL();
      setState(() {
        imageUrl = url;
        loading_screen = false;
      });
      print("URL fetched successfully.");
    } catch (e) {
      print("Getting exepetion : " + e.toString());
    }
  }

  Future<void> _showPicker(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                ),
                title: const Text(
                  'Gallery',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  try {
                    var get_image = await image_picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    image = File(get_image!.path);
                    Navigator.pop(context);
                    int fileSizeInBytes = image!.lengthSync();
                    double fileSizeInMb = fileSizeInBytes / (1024 * 1024);
                    print(
                        'Selected image size: ${fileSizeInMb.toStringAsFixed(2)} MB');
                    if (fileSizeInMb > 3) {
                      try {
                        print("Picture compression started");

                        final directory =
                            await getApplicationDocumentsDirectory();
                        final targetPath =
                            '${directory.path}/profile_pic/${widget.user_id}';

                        var compressedFile =
                            await FlutterImageCompress.compressAndGetFile(
                          image!.absolute.path,
                          targetPath,
                          quality: 50,
                        );

                        setState(() {
                          image = compressedFile! as File?;
                        });

                        print("Picture compression completed");
                      } catch (e) {
                        print("error in image compresser... " + e.toString());
                      }
                    }
                    update_profile_pic();
                  } catch (e) {
                    print("Getting exception : " + e.toString());
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Colors.white,
                ),
                title: const Text(
                  'Camera',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () async {
                  try {
                    var get_image = await image_picker.pickImage(
                      source: ImageSource.camera,
                    );
                    image = File(get_image!.path);
                    Navigator.pop(context);
                    int fileSizeInBytes = image!.lengthSync();
                    double fileSizeInMb = fileSizeInBytes / (1024 * 1024);
                    print(
                        'Selected image size: ${fileSizeInMb.toStringAsFixed(2)} MB');
                    if (fileSizeInMb > 3) {
                      try {
                        print("Picture compression started");

                        final directory =
                            await getApplicationDocumentsDirectory();
                        final targetPath =
                            '${directory.path}/profile_pic/${widget.user_id}';

                        var compressedFile =
                            await FlutterImageCompress.compressAndGetFile(
                          image!.absolute.path,
                          targetPath,
                          quality: 50,
                        );

                        setState(() {
                          image = compressedFile! as File?;
                        });

                        print("Picture compression completed");
                        update_profile_pic();
                      } catch (e) {
                        print("error in image compresser... " + e.toString());
                      }
                    }
                    update_profile_pic();
                  } catch (e) {
                    print("Getting exception : " + e.toString());
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> update_profile_pic() async {
    print("Image updating started.");
    setState(() {
      loading_screen = true;
    });
    try {
      if (userData!['profile_pic'] == "/profilePhoto/Defalt_image.jpg") {
        final path = "profilePhoto/${widget.user_id}.jpg";

        final ref = FirebaseStorage.instance.ref().child(path);
        UploadTask? up = ref.putFile(image!);

        final snapshot = await up.whenComplete(() {});

        final CollectionReference users =
            FirebaseFirestore.instance.collection(widget.user_id);
        final DocumentReference docRef = users.doc("User_information");
        await docRef.set({
          'about': userData!['about'],
          'first_name': userData!['first_name'],
          'last_name': userData!['last_name'],
          'mail': userData!['mail'],
          'mobile_number': userData!['mobile_number'],
          'password': userData!['password'],
          'profile_pic': path,
          'user_name': userData!['user_name'],
          'status': userData!['status'],
          'user_id': userData!['user_id']
        });
      } else {
        // final path = "profilePhoto/${widget.user_id}.jpg";

        // final ref = FirebaseStorage.instance.ref().child(path);
        // ref.delete();
        // UploadTask? up = ref.putFile(image!);
        final path = "profilePhoto/${widget.user_id}.jpg";
        final ref = FirebaseStorage.instance.ref().child(path);

        // Check if the object exists
        try {
          await ref.getDownloadURL();
          // Object exists, proceed with deletion
          await ref.delete();
          print("Existing image deleted.");
        } catch (e) {
          if (e is FirebaseException && e.code == 'object-not-found') {
            print("No existing image found to delete.");
          } else {
            throw e;
          }
        }

        // Upload the new image
        UploadTask uploadTask = ref.putFile(image!);
        await uploadTask.whenComplete(() {});
      }
      print("profile_pic is updated.");
    } catch (e) {
      print("Cannot update image! Getting exception : " + e.toString());
      _showUnableToUploadImageDialog();
    } finally {
      await image!.delete();
      setState(() {
        loading_screen = false;
      });
      setState(() {
        get_user_details();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loading_screen = true;
    imageUrl = "";
    get_user_details();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          loading_screen
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: const BoxDecoration(color: Colors.black),
                )
              : AnimatedContainer(
                  duration: const Duration(),
                  decoration: const BoxDecoration(color: Colors.black),
                  child: ListView(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Stack(
                            children: [
                              Container(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: CircleAvatar(
                                    radius: 70.0,
                                    backgroundColor: Colors.blue,
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: imageUrl,
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
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Add your onPressed code here!
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.blue,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(
                                        10), // Splash color
                                  ),
                                  child: GestureDetector(
                                    child: const Icon(
                                      Icons.edit,
                                      size: 20,
                                    ),
                                    onTap: () {
                                      _showPicker(context);
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: AnimatedContainer(
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            border: Border(
                              bottom:
                                  BorderSide(color: Colors.blue, width: 0.3),
                            ),
                          ),
                          duration: const Duration(),
                          child: Material(
                            color: Colors.black,
                            child: ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 30,
                              ),
                              title: Text(
                                userData!['user_name'],
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              subtitle: const Text(
                                "This is your username. This name will be visible to your friends in S Messages.",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 199, 198, 198),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.edit,
                                size: 30,
                                color: Colors.blue,
                              ),
                              onTap: () {
                                getUsernameModalBottomSheet(context);
                              },
                              splashColor:
                                  const Color.fromARGB(90, 255, 255, 255),
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          border: Border(
                            bottom: BorderSide(color: Colors.blue, width: 0.3),
                          ),
                        ),
                        duration: const Duration(),
                        child: Material(
                          color: Colors.black,
                          child: ListTile(
                            leading: const Icon(
                              Icons.info,
                              color: Colors.blue,
                              size: 30,
                            ),
                            title: const Text(
                              "About",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 199, 198, 198),
                                  fontSize: 15),
                            ),
                            subtitle: Text(
                              userData!['about'],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                            ),
                            trailing: const Icon(
                              Icons.edit,
                              size: 30,
                              color: Colors.blue,
                            ),
                            onTap: () {
                              getAboutModalBottomSheet(context);
                            },
                            splashColor:
                                const Color.fromARGB(90, 255, 255, 255),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        height: 100,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          border: Border(
                            bottom: BorderSide(color: Colors.blue, width: 0.3),
                          ),
                        ),
                        duration: const Duration(),
                        child: Material(
                          color: Colors.black,
                          child: ListTile(
                            leading: const Icon(
                              Icons.call,
                              color: Colors.blue,
                              size: 30,
                            ),
                            trailing: const Icon(
                              Icons.verified_user,
                              size: 30,
                              color: Colors.blue,
                            ),
                            title: const Text(
                              "Phone",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 199, 198, 198),
                                  fontSize: 15),
                            ),
                            subtitle: Text(
                              userData!['mobile_number'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 50, horizontal: (size.width / 2 - 100)),
                        child: ElevatedButton(
                          onPressed: () {
                            _showlogoutDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            shape: const StadiumBorder(),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              "Logout",
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
                    color: Color.fromARGB(30, 0, 0, 0),
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
