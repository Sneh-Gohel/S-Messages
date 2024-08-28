// ignore_for_file: file_names, camel_case_types, must_be_immutable

import 'package:flutter/material.dart';

class Chat_bubble extends StatelessWidget {
  String message;
  String send;
  Chat_bubble({super.key, required this.message, required this.send});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: send == "true" ? Colors.blue : Colors.blueGrey,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}
