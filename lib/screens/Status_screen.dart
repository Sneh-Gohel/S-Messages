// ignore_for_file: file_names, camel_case_types, non_constant_identifier_names, avoid_unnecessary_containers

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:s_messages/screens/Chat_room_screen.dart';

class Status_screen extends StatefulWidget {
  String user_id;
  String reciver_user_id;
  String reciver_user_name;
  String chat_id;
  String reciver_imageURL;
  String status;
  Status_screen(this.user_id, this.reciver_user_id, this.reciver_user_name,
      this.chat_id, this.reciver_imageURL, this.status,
      {super.key});

  @override
  State<StatefulWidget> createState() => _Status_screen();
}

class _Status_screen extends State<Status_screen>
    with SingleTickerProviderStateMixin {
  late Future<String> _imageUrlFuture;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool hold = false;

  Future<String> _loadImageUrl() async {
    // Get the image download URL from Firebase Storage
    return await FirebaseStorage.instance.ref(widget.status).getDownloadURL();
  }

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = _loadImageUrl();
    // Initialize the animation controller with a 3-second duration
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Tween from 0.0 to 1.0 over 3 seconds
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {}); // Rebuild the widget with updated progress
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.pop(context);
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.chat_id == ''
          ? AppBar(
              title: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.reciver_imageURL,
                            placeholder: (context, url) => const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.person, size: 60),
                              ],
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 30.0,
                              height: 30.0,
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
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Flexible(
                      child: Text(
                        widget.reciver_user_name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            )
          : AppBar(
              title: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.reciver_imageURL,
                            placeholder: (context, url) => const Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(Icons.person, size: 60),
                              ],
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            imageBuilder: (context, imageProvider) => Container(
                              width: 30.0,
                              height: 30.0,
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
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Flexible(
                      child: Text(
                        widget.reciver_user_name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              actions: [
                PopupMenuButton(
                  offset: const Offset(0, 48),
                  color: const Color.fromRGBO(30, 25, 38, 1.0),
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'Chats',
                        child: Text(
                          'Chats',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ];
                  },
                  onOpened: () {
                    _controller.stop();
                  },
                  onCanceled: () {
                    _controller.forward();
                  },
                  onSelected: (value) {
                    if (value == "Chats") {
                      _controller.stop();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  Chat_room_screen(
                                      widget.user_id,
                                      widget.reciver_user_id,
                                      widget.reciver_user_name,
                                      widget.chat_id,
                                      widget.reciver_imageURL),
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
                    }
                  },
                ),
              ],
            ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_controller.isAnimating) {
                _controller.stop();
              } else {
                _controller.forward();
              }
            },
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! > 10) {
                Navigator.pop(context);
              }
            },
            onLongPressStart: (details) {
              _controller.stop(); // Pause on long press
            },
            onLongPressEnd: (details) {
              _controller
                  .forward(); // Resume after long press release if not paused
            },
            child: Container(
              decoration: const BoxDecoration(color: Colors.black),
              child: Center(
                child: FutureBuilder<String>(
                  future: _imageUrlFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Show the progress indicator while loading the image URL
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // Handle any errors that occurred during the loading
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      // Image URL successfully loaded, show the image with a smooth transition
                      _controller.forward();
                      return CachedNetworkImage(
                        imageUrl: snapshot.data!,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        imageBuilder: (context, imageProvider) => FadeInImage(
                          placeholder:
                              const AssetImage('assets/placeholder.png'),
                          image: imageProvider,
                          fadeInDuration: const Duration(milliseconds: 200),
                          fit: BoxFit.cover,
                        ),
                      );
                    } else {
                      // Fallback for any other unexpected scenarios
                      return const Text('Unexpected error occurred');
                    }
                  },
                ),
              ),
            ),
          ),
          Container(
            child: LinearProgressIndicator(
              value: _animation.value,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[500]!),
            ),
          ),
        ],
      ),
    );
  }
}
