import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:s_messages/services/GetAcceessToken.dart';

class FCMService {
  final String serviceAccountJsonPath;
  final String projectId;

  FCMService(this.serviceAccountJsonPath, this.projectId);

  Future<void> sendNotification(String title, String body, String token) async {
    // final accessToken = await getAccessToken();
    GetAceessToken gat = GetAceessToken();
    String accessToken = await gat.getaccessToken();
    final url =
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

    final message = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        }
      }
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }
}
