import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:comt/model/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:comt/config.dart';
import 'dart:convert';
import '../main.dart';
import '../UserData.dart';
import '../pages/login_page.dart';

// 사용자의 상태를 관리(사용자 정보, 로그인 여부 등)
class UserViewModel extends ChangeNotifier {
  String _nickname = '';
  String _kakaoId = '';
  bool _isLoggedIn = false;

  //private 변수를 외부에서 읽을 수 있도록 해주는 getter 메소드
  String get nickname => _nickname;
  String get kakaoId => _kakaoId;
  bool get isLoggedIn => _isLoggedIn;

  // 생성자
  UserViewModel() {
    _loadUserInfo();
  }

  // SharedPreferences에서 정보를 로드하고 클래스의 상태 설정
  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _nickname = prefs.getString('nickname') ?? '';
    _kakaoId = prefs.getString('kakao_id') ?? '';
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    notifyListeners();
  }

  Future<void> _saveUserInfo(String nickname, String kakaoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
    await prefs.setString('kakao_id', kakaoId);
    await prefs.setBool('is_logged_in', true);
    _nickname = nickname;
    _kakaoId = kakaoId;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nickname');
    await prefs.remove('kakao_id');
    await prefs.setBool('is_logged_in', false);
    _nickname = '';
    _kakaoId = '';
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> fetchAndSaveUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      await _saveUserInfo(user.kakaoAccount?.profile?.nickname ?? '', user.id.toString());
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  Future<bool> checkLoginStatus() async {
    try {
      var tokenInfo = await UserApi.instance.accessTokenInfo();
      if (tokenInfo != null) {
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        _isLoggedIn = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loginWithKakao(BuildContext context) async {
    print('카카오 로그인1');
    KakaoSdk.init(nativeAppKey: Config.appKey);
    OAuthToken? token;
    print('카카오 로그인2');
    if (await isKakaoTalkInstalled()) {
      try {
        print('카카오 로그인3');
        token=await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공 ${token.accessToken}');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        try {
          print('카카오 로그인4');
          token=await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }


    if(token!=null){
      final response = await http.post(
        Uri.parse('${Config.baseUrl}sendCode'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token.accessToken, // 토큰 정보를 포함하여 서버로 전송
        }),
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('서버 응답: $responseBody');
        if (responseBody['exists']) {
          // 유저 정보가 있는 경우
          UserData.instance.setUserData(
            responseBody['userInfo']['uniqueId'].toString(),
            responseBody['userInfo']['nickname'],
            responseBody['userInfo']['profile_image_url'],
          );
          UserData.instance.setKakaoId(responseBody['userInfo']['kakaoId']);
          print('홈홈페이지로 이동합니다');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home')),
          );
        }
        else{
          print('계정 없음');
          UserData.instance.setDefaultUrl(responseBody['imgUrl']);
          UserData.instance.setKakaoId(responseBody['kakaoId']);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => ProfileSetupPage()),
          );
        }
      }else{
        print('카카오 아이디 기록 없음');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }
    /*
    response = await http.post(
      Uri.parse('${Config.baseUrl}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': 'aaa',
        'password': 'aaaa',
      }),
    );

     */

  }

  Future<void> _handleLoginSuccess(OAuthToken token, BuildContext context) async {
    bool success = await UserService.getUserInfoAndSendToServer(token); //카카오에서 정보를 받아 서버로 전송
    if (success) {
      await fetchAndSaveUserInfo(); //상태에 업데이트
      Navigator.pushReplacementNamed(context, '/home'); // 홈화면으로 이동
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버로 사용자 정보 전송 실패. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await UserApi.instance.logout();
      print('카카오 로그아웃 함수 완료');
      await clearUserInfo();
      print('로그아웃 완료');
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }
}
