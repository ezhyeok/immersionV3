import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PostData {
  final String problemNum;
  final String result;
  final String codeURL;
  final String content;

  PostData({
    required this.problemNum,
    required this.result,
    required this.codeURL,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'problemNum': problemNum,
      'result': result,
      'codeURL': codeURL,
      'content': content,
    };
  }
}

class PostApiService {
  static const String baseUrl = 'http://192.168.227.4:8080';

  Future<void> submitPost(PostData postData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response = await http.post(
      Uri.parse('$baseUrl/posts/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(postData.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit post');
    }
  }
}