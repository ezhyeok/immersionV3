import 'dart:async'; // Timer를 위한 import
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:comt/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart'; // 권한 요청 패키지 임포트
import 'package:android_intent_plus/android_intent.dart'; // 배터리 최적화 설정용 패키지 임포트
import 'package:app_usage/app_usage.dart';
import 'package:flutter/services.dart';  // 플랫폼 채널 사용을 위한 임포트
import 'pages/home_page.dart';
import 'pages/todo_page.dart';
import 'package:comt/pages/analysis_page.dart';
import 'package:comt/pages/stop_page.dart';

import 'pages/login_page.dart';
import 'package:comt/config.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:alarm/alarm.dart';  // 알람 패키지 임포트
import 'package:android_intent_plus/android_intent.dart';  // 배터리 최적화 설정용 패키지 임포트
import 'dart:async';
import 'package:android_intent_plus/android_intent.dart';
import 'package:app_to_foreground/app_to_foreground.dart';



Future initialization() async {
  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
}

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  KakaoSdk.init(nativeAppKey: Config.appKey); // 카카오 SDK 초기화
  await Alarm.init(); // 알람 초기화
  await initialization();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserViewModel()),
      ],
      child: MyApp(),
    ),
  );
}


/*
Future initialization() async {
  await Future.delayed(const Duration(seconds: 1));
  FlutterNativeSplash.remove();
}

 */

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CheckLogin(),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _pages = <Widget>[
    todoPage(),
    homePage(),
    analysisPage(),
    // HomePage(),
    // PicksPage(),
  ];
  static const platform = MethodChannel('com.example.alquerithm/alarm');

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
  }
  Future<void> _setRepeatingAlarm() async {
    print('setRepeatingAlarm 호출됨');
    DateTime now = DateTime.now();
    DateTime firstAlarm = DateTime(now.year, now.month, now.day, now.hour, now.minute + 3); // 다음 1분 단위로 설정
    print('첫 알람 시간: $firstAlarm');
    await _setAlarm(firstAlarm);

    Timer.periodic(Duration(minutes: 3), (timer) async {
      print('1분이 지남');
      DateTime alarmTime = DateTime.now().add(Duration(minutes: 3));
      print('다음 알람 시간: $alarmTime');
      await _setAlarm(alarmTime);
    });
  }
  Future<void> _setAlarm(DateTime alarmTime) async {
    int phoneUsingTime = await _fetchPhoneUsageTime();
    String notificationBody = '오늘 휴대폰 사용시간: ${phoneUsingTime ~/ 60}h ${phoneUsingTime % 60}m';

    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: 42,
        dateTime: alarmTime,
        assetAudioPath: '',
        loopAudio: false,
        vibrate: false,
        fadeDuration: 3.0,
        notificationTitle: notificationBody,
        notificationBody: '',
        enableNotificationOnKill: false,
        androidFullScreenIntent: true,
      ),
    );
  }
  Future<int> _fetchPhoneUsageTime() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day); // 오늘의 시작 시간

    try {
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);
      int phoneUsingTime = infoList.fold(0, (sum, info) => sum + info.usage.inMinutes);
      return phoneUsingTime;
    } catch (e) {
      print("Failed to get app usage: $e");
      return 0;
    }
  }


  // Future<void> _logout() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('jwt_token');
  //   Navigator.of(context).pushReplacement(
  //     MaterialPageRoute(builder: (context) => LoginPage()),
  //   );
  // }
  /*
  void setRepeatingAlarm() async {
    print('setRepeatingAlarm 호출됨');
    DateTime now = DateTime.now();
    DateTime firstAlarm = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1); // 다음 1분 단위로 설정

    print('첫 알람 시간: $firstAlarm');
    await Alarm.set(
      alarmSettings: AlarmSettings(
        id: 42,
        dateTime: firstAlarm,
        assetAudioPath: '',
        loopAudio: false,
        vibrate: false,
        fadeDuration: 3.0,
        notificationTitle: '',
        notificationBody: '',
        enableNotificationOnKill: false,
        androidFullScreenIntent: true,
      ),
    );



    Timer.periodic(Duration(minutes: 1), (timer) async {
      print('1분이 지남');
      DateTime alarmTime = DateTime.now().add(Duration(minutes: 1));
      print('다음 알람 시간: $alarmTime');
      await Alarm.set(
        alarmSettings: AlarmSettings(
          id: 42,
          dateTime: alarmTime,
          assetAudioPath: '',
          loopAudio: false,
          vibrate: false,
          fadeDuration: 3.0,
          notificationTitle: '',
          notificationBody: '',
          enableNotificationOnKill: false,
          androidFullScreenIntent: true,
        ),
      );
    });
  }

   */

  void openBatteryOptimizationSettings() {
    final intent = AndroidIntent(
      action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
    );
    intent.launch();
  }
  Future<void> checkBatteryOptimizationPermission() async {
    var status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }
  Future<void> bringAppToForeground() async {
    try {
      print("Try to bring app to foreground");
      await platform.invokeMethod('bringToForeground');
      print("Finish bring app to foreground");

    } on PlatformException catch (e) {
      print("Failed to bring app to foreground: '${e.message}'.");
    }
  }
  @override
  void initState() {
    super.initState();
    _setRepeatingAlarm();
    checkBatteryOptimizationPermission();
    Alarm.ringStream.stream.listen((_) {
      print('알람 이벤트 수신됨');
      //bringAppToForeground();
      AppToForeground.appToForeground();
      _onAlarmRing();
    });
  }
  void _onAlarmRing() {
    Future.delayed(Duration(milliseconds: 100), () {
      Navigator.push(
        context, MaterialPageRoute(builder: (context) => animation(),),
      );
    });
    /*
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ()),
    );

     */
  }
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/img/COMT-clock.png', height: 55,),
        centerTitle: true,
        backgroundColor: Colors.white,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.logout, color: Color(0xFFFFA423)),
        //     onPressed: _logout,
        //   ),
        // ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add_check),
            label: 'TODO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'ANALYSIS',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF4BA933),
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(color: Color(0xFF4BA933)),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
      ),
      backgroundColor: Colors.white,
    );
  }
}
class AlarmScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알람이 울리고 있습니다!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('１분이 지났습니다!'),
            ElevatedButton(
              onPressed: () async {
                print('알람 중지 버튼 클릭됨');
                try {
                  await Alarm.stop(42);
                  print('알람이 중지되었습니다.');
                } catch (e) {
                  print('알람 중지 중 오류 발생: $e');
                }
                Navigator.pop(context);
              },
              child: Text('알람 중지'),
            ),
          ],
        ),
      ),
    );
  }
}
