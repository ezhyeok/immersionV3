import 'package:comt/pages/todo_page.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:comt/view_model/user_view_model.dart';
import '../main.dart';
import '../UserData.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:comt/config.dart';
import 'package:comt/pages/todo_page.dart';

import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart'; // MediaType을 사용하기 위해 추가


class CheckLogin extends StatefulWidget {
  @override
  _CheckLoginState createState() => _CheckLoginState();
}

class _CheckLoginState extends State<CheckLogin> {
  bool _check() {
    return false;
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  _checkLoginStatus() async {
    if(await AuthApi.instance.hasToken()){
      try{
        AccessTokenInfo tokenInfo = await UserApi.instance.accessTokenInfo();
        OAuthToken? token2 = await TokenManagerProvider.instance.manager.getToken();
        var accessToken='None';
        if(token2!=null) {
          accessToken = token2.accessToken;
        }
        print('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
        print('토큰2 $accessToken');
        // 토큰을 서버로 전송

        final response = await http.post(
          Uri.parse('${Config.baseUrl}sendCode'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'token': accessToken, // 토큰 정보를 포함하여 서버로 전송
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

        /*
        tokenInfo.accesstoken을 보내고 exists가 true면
        void setUserData(String id, String name, String url) {
          uniqueId = id;
          nickName = name;
          profileImageUrl = url;
        }
        를 통해서 받은 값을 싱글톤으로 저장하게 함
        */


      }catch(error){
        print('에러가 발생했습니다 $error');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    }else{
      print('카카오 아이디 기록 없음');
      UserData.instance.setUserData(
        '1',
        '치킨',
        'http://34.125.165.162:3000/uploads/kakaoprofile/3621951250.jpg',
      );
      UserData.instance.setKakaoId('3621951250');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home')),
      );
    }







/*
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token != null) {

    } else {
    }

 */

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
/*
class InformPage extends StatefulWidget {
const LoginPage({super.key});


 */




class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();

  Future<void> _login() async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("백준 로그인 중.."),
              ],
            ),
          ),
        );
      },
    );

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/login'),
      body: json.encode({
        'username': _idController.text,
        'password': _pwController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final token = responseBody['access_token'];
      print("--------------------------------------------------------------");
      print("token at login -> $token");
      // SharedPreferences에 토큰 저장
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // 로그인 성공 알림창
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('로그인 성공!', textAlign: TextAlign.center,),
          );
        },
      );

      // 0.8초 뒤에 메인 화면으로 이동
      Future.delayed(Duration(milliseconds: 800), () {
        Navigator.of(context).pop();  // 알림창 닫기
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home')),
        );
      });
    } else {
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // Handle error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('로그인 실패'),
            content: Text('아이디 또는 비밀번호를 확인하세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      backgroundColor: Color(0xFFF7FFFB),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지 추가 부분
              Image.asset(
                'assets/img/comt_logo.png',
                fit: BoxFit.contain,
                width: 300, // 로고 이미지의 너비를 설정
              ),
              SizedBox(height: 20), // 로고와 카드 사이의 간격 추가
              Card(
                color: Colors.white,
                child: Container(
                  height: 320, // 높이를 증가하여 이미지 추가 공간 확보
                  width: 400,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _idController,
                        decoration: InputDecoration(labelText: "id 입력"),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        obscureText: true,
                        controller: _pwController,
                        decoration: InputDecoration(labelText: "pw 입력"),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              foregroundColor: Color(0xFF49454F),
                              backgroundColor: Colors.white,
                              side: BorderSide(width: 1, color: Color(0xFF49454F)),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage()),
                              );
                            },
                            child: Text('회원가입'),
                          ),
                          SizedBox(width: 20),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              foregroundColor: Colors.white,
                              backgroundColor: Color(0xFF49454F),
                            ),
                            onPressed: _login,
                            child: Text('로그인'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          print('버튼이 눌렸습니다');
                          userViewModel.loginWithKakao(context);
                        },
                        child: Container(
                          width: 250,
                          height: 38,
                          child: Image.asset(
                            'assets/img/kakao_login_medium_wide.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfileSetupPage extends StatefulWidget {
  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  File? _profileImage;
  TextEditingController _nicknameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
  Future<void> _uploadImageToServer(File imageFile) async {
    var uri = Uri.parse('${Config.baseUrl}upload/kakaoimage'); // 서버 URL로 변경하세요
    var request = http.MultipartRequest('POST', uri);

    // Add text fields
    request.fields['kakaoId'] = UserData.instance.kakaoId!;

    // Add image file
    var mimeTypeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8])?.split('/');
    var file = await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: mimeTypeData != null ? MediaType(mimeTypeData[0], mimeTypeData[1]) : null,
    );

    request.files.add(file);

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        print('Image upload successful');
        String imageUrl = '${Config.baseUrl}uploads/kakaoprofile/${UserData.instance.kakaoId}.jpg';
        _sendProfileInfo(UserData.instance.kakaoId!, _nicknameController.text!, imageUrl!);
        // 서버 응답 처리
      } else {
        print('Image upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Image upload failed: $e');
    }
  }
  Future<void> _sendProfileInfo(String kakaoId, String nickname, String imageUrl) async {
    var uri = Uri.parse('${Config.baseUrl}permission'); // 서버 URL로 변경하세요
    var request = {
      'kakaoId': kakaoId,
      'nickname': nickname,
      'imageUrl': imageUrl,
    };

    try {
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        print('Profile info sent successfully: $responseBody');
        UserData.instance.setUserData(
          responseBody['userInfo']['uniqueId'],
          responseBody['userInfo']['nickname'],
          responseBody['userInfo']['profile_image_url'],
        );
        UserData.instance.setKakaoId(responseBody['userInfo']['kakaoId']);

        print('이동 준비를 마쳤습니다');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home')),
        );

      } else {
        print('Failed to send profile info: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Request failed: $e');
    }
  }

  void _saveProfile() {
    String nickname = _nicknameController.text;
    // Implement saving profile logic here, e.g., sending data to a server or saving locally

    print('Nickname: $nickname');
    if (_profileImage != null) {
      _uploadImageToServer(_profileImage!);
      /*
      이 부분에 그러한 요청을 보내게 작성해줘
      kakaoId는 UserData.instance.kakaoId!, nickname은 _nicknameController.text, imageurl은 "http://34.125.165.162:3000/uploads/kakaoprofile/${kakaoId}.jpg" 이야
      */
      print('Profile Image Path: ${_profileImage!.path}');

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Up Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : (UserData.instance.profileImageUrl != null
                      ? NetworkImage(UserData.instance.profileImageUrl!)
                      : AssetImage('assets/img/0.png')) as ImageProvider,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: 'Nickname',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}









class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _idController = TextEditingController();
  TextEditingController _pwController = TextEditingController();
  TextEditingController _bojIdController = TextEditingController();

  Future<void> _register() async {
    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("회원가입 중.."),
              ],
            ),
          ),
        );
      },
    );

    final response = await http.post(
      Uri.parse('http://192.168.227.4:8080/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': _idController.text,
        'password': _pwController.text,
        'boj_username': _bojIdController.text,
      }),
    );

    if (response.statusCode == 200) {
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // 회원가입 성공 알림창
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('회원가입 성공!', textAlign: TextAlign.center,),
          );
        },
      );

      // 0.8초 뒤에 로그인 페이지로 이동
      Future.delayed(Duration(milliseconds: 800), () {
        Navigator.of(context).pop();  // 알림창 닫기
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    } else {
      // 로딩 다이얼로그 닫기
      Navigator.of(context).pop();

      // Handle error
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('회원가입 실패'),
            content: Text('입력한 정보를 확인하세요.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFA423),
      body: Center(
        child: Card(
          color: Colors.white,
          child: Container(
            height: 280,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _idController,
                    decoration: InputDecoration(labelText: "id 입력"),
                  ),
                ),
                Expanded(
                  child: TextField(
                    obscureText: true,
                    controller: _pwController,
                    decoration: InputDecoration(labelText: "pw 입력"),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _bojIdController,
                    decoration: InputDecoration(labelText: "BOJ id 입력"),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    height: 20,
                  ),
                ),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      foregroundColor: Color(0xFF49454F),
                      backgroundColor: Colors.white,
                      side: BorderSide(width: 1, color: Color(0xFF49454F)),
                    ),
                    onPressed: _register,
                    child: Text('회원가입'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}