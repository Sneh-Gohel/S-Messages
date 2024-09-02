// ignore_for_file: file_names, camel_case_types, must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:s_messages/screens/Chat_bubble.dart';
import 'package:s_messages/services/Chat_services.dart';

class Chat_room_screen extends StatefulWidget {
  String user_id;
  String reciver_user_id;
  String reciver_user_name;
  String chat_id;
  String reciver_imageURL;
  String current_user_name;
  String reciver_fcm;

  Chat_room_screen(this.user_id, this.reciver_user_id, this.reciver_user_name,
      this.chat_id, this.reciver_imageURL, this.current_user_name,this.reciver_fcm,
      {super.key});

  @override
  State<StatefulWidget> createState() => _Chat_room_screen();
}

class _Chat_room_screen extends State<Chat_room_screen> {
  final message_controller = TextEditingController();
  final message = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _isAtBottom = ValueNotifier<bool>(true);
  var chat_details;
  bool new_message = false;

  Future<void> get_chat_details() async {
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('Chat_rooms')
        .doc(widget.chat_id)
        .get();
    chat_details = docSnapshot.data() as Map<String, dynamic>;
    update_messages_status();
  }

  Future<void> update_messages_status() async {
    await FirebaseFirestore.instance
        .collection('Chat_rooms')
        .doc(widget.chat_id)
        .update({widget.user_id: 'No', '${widget.user_id}_timestamp': "None"});
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent - 50) {
        _isAtBottom.value = true;
      } else {
        _isAtBottom.value = false;
      }
    });
    get_chat_details();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    message_controller.dispose();
    _isAtBottom.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: null,
              icon: Icon(
                Icons.call,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: null,
              icon: Icon(
                Icons.videocam,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.black),
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildMessageInput(),
              ],
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isAtBottom,
              builder: (context, isAtBottom, child) {
                return AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  bottom: isAtBottom ? -60 : 80,
                  right: 10,
                  child: FloatingActionButton(
                    onPressed: () {
                      _scrollToBottom();
                    },
                    child: const Icon(Icons.arrow_downward),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // build message list
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: Chat_services()
          .getMessages(widget.user_id, widget.reciver_user_id, widget.chat_id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map<Widget>((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var alignment = (data['sender_id'] == widget.user_id)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    if (chat_details[widget.user_id] == "Yes") {
      if (new_message == false) {
        Timestamp t1 = data['timestamp'];
        Timestamp t2 = chat_details['${widget.user_id}_timestamp'];

        DateTime dt1 = t1.toDate();
        DateTime dt2 = t2.toDate();

        if (dt1.isAfter(dt2) || dt1.isAtSameMomentAs(dt2)) {
          new_message = true;
          return Column(
            children: [
              Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _newMessageDisplay(),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: alignment,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: data['sender_id'] == widget.user_id
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisAlignment: data['sender_id'] == widget.user_id
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Chat_bubble(
                        message: data['message'],
                        send: data['sender_id'] == widget.user_id
                            ? "true"
                            : "false",
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return Container(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: data['sender_id'] == widget.user_id
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisAlignment: data['sender_id'] == widget.user_id
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Chat_bubble(
                      message: data['message'],
                      send: data['sender_id'] == widget.user_id
                          ? "true"
                          : "false")
                ],
              ),
            ),
          );
        }
      } else {
        return Container(
          alignment: alignment,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: data['sender_id'] == widget.user_id
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisAlignment: data['sender_id'] == widget.user_id
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Chat_bubble(
                    message: data['message'],
                    send:
                        data['sender_id'] == widget.user_id ? "true" : "false")
              ],
            ),
          ),
        );
      }
    } else {
      return Container(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: data['sender_id'] == widget.user_id
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: data['sender_id'] == widget.user_id
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Chat_bubble(
                  message: data['message'],
                  send: data['sender_id'] == widget.user_id ? "true" : "false")
            ],
          ),
        ),
      );
    }
  }

  // build message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
            child: TextField(
              controller: message_controller,
              focusNode: message,
              onEditingComplete: () {
                message.unfocus();
              },
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                suffix: GestureDetector(
                  child: const Icon(Icons.clear, color: Colors.white),
                  onTap: () {
                    message_controller.clear();
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
                hintText: "Message...",
                hintStyle: const TextStyle(color: Colors.white),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.white),
          onPressed: () async {
            if (message_controller.text.isNotEmpty) {
              await Chat_services().sendMessage(
                  widget.user_id,
                  widget.reciver_user_id,
                  message_controller.text,
                  widget.chat_id,
                  widget.current_user_name,
                  "chat",widget.reciver_fcm);
              message_controller.clear();
              _scrollToBottom();
            }
          },
        ),
      ],
    );
  }

  Widget _newMessageDisplay() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Text(
              "New Messages",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
