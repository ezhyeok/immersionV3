import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:comt/config.dart';
class UserService {
  static Future<bool> getUserInfoAndSendToServer(OAuthToken token) async {
    try {
      User user = await UserApi.instance.me();
      return await sendUserInfoToServer(user, token);
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
      return false;
    }
  }

  static Future<bool> sendUserInfoToServer(User user, OAuthToken token) async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/auth/kakao/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'kakao_id': user.id.toString(),
        'nickname': user.kakaoAccount?.profile?.nickname ?? '',
      }),
    );

    if (response.statusCode == 200) {
      print('사용자 정보 저장 성공');
      return true;
    } else {
      print('사용자 정보 저장 실패');
      return false;
    }
  }
}
