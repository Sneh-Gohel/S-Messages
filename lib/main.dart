import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:s_messages/firebase_options.dart';
import 'package:s_messages/screens/Starting_screen.dart';
import 'package:s_messages/services/PushNotifications.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// Function for handling background notifications
Future<void> _firebaseBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Handle background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Background navigator tapped....");
    navigatorKey.currentState!.pushNamed("/Message", arguments: message.data);
  });

  // Initialize push notifications
  PushNotifications.init();
  PushNotifications.localNotificationinit();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // to handle foreground notifications...
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print("Got a foreground message.");

  if (message.notification != null) {
    // Extracting data from RemoteMessage
    final title = message.notification!.title ?? 'No Title';
    final body = message.notification!.body ?? 'No Body';
    final data = message.data;

    // Converting the extracted data to a JSON string
    String payloadData = jsonEncode({
      'title': title,
      'body': body,
      'data': data,
    });

    // Display the notification
    PushNotifications.showSimpleNotification(
      title: title,
      body: body,
      payload: payloadData,
    );
  }
});

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'S Messages',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Starting_screen(),
    );
  }
}
