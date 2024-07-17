import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PickData {
  late List<List<dynamic>> pick_problems;
  late String least_tag;
  late List<List<dynamic>> least_tag_problems;
  late String most_tag;
  late List<List<dynamic>> most_tag_problems;

  PickData({
    required this.pick_problems,
    required this.least_tag,
    required this.least_tag_problems,
    required this.most_tag,
    required this.most_tag_problems,
  });

  factory PickData.fromJson(Map<String, dynamic> json) {
    return PickData(
      pick_problems: List<List<dynamic>>.from(json['pick_problems']),
      least_tag: json['least_tag'],
      least_tag_problems: List<List<dynamic>>.from(json['least_tag_problems']),
      most_tag: json['most_tag'],
      most_tag_problems: List<List<dynamic>>.from(json['most_tag_problems']),
    );
  }
}

class PickApiService {
  static const String apiUrl = "http://192.168.227.4:8080"; // API URL을 설정합니다.

  Future<PickData> fetchPickData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse("$apiUrl/users/picks/"),
      headers: {
        'Authorization': 'Bearer $token', // 필요한 경우 토큰을 추가합니다.
      },
    );

    if (response.statusCode == 200) {
      return PickData.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load pick data');
    }
  }
}