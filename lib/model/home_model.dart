import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeData {
  final String bojUsername;
  final int tier;
  final List<String> userTags;
  final int aliasNum;
  final int todaySolved;

  HomeData({
    required this.bojUsername,
    required this.tier,
    required this.userTags,
    required this.aliasNum,
    required this.todaySolved,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      bojUsername: json['boj_username'],
      tier: json['tier'],
      userTags: List<String>.from(json['user_tags']),
      aliasNum: json['alias_num'],
      todaySolved: json['today_solved'],
    );
  }
}



class HomeApiService {
  static const String baseUrl = 'http://192.168.227.4:8080';

  Future<HomeData> fetchHomeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response = await http.get(
      Uri.parse('$baseUrl/users/home'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return HomeData.fromJson(data);
    } else {
      throw Exception('Failed to load home data');
    }
  }
}