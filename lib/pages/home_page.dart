import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:http/http.dart' as http;
import 'package:comt/UserData.dart';
import 'package:comt/config.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:app_usage/app_usage.dart';

import '../widgets/font.dart';

class app {
  String id;
  int usingTime;

  app(this.id, this.usingTime);
}

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  List<app> appList = [];

  Future<double> _fetchCompletionRate() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}getTodoRate?uniqueId=${UserData.instance.uniqueId}&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      return double.parse(data['rate'].toString());
    } else {
      throw Exception('Failed to load completion rate');
    }
  }

  Future<void> _fetchAppUsage() async {
    DateTime endDate = DateTime.now();
    DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day); // 오늘의 시작 시간

    try {
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);

      setState(() {
        appList = infoList
            .where((info) => info.usage.inMinutes > 0) // 0분 사용한 앱 제외
            .map((info) => app(info.appName, info.usage.inMinutes))
            .toList();

        appList.sort((a, b) => b.usingTime.compareTo(a.usingTime)); // 사용 시간 많은 순으로 정렬
      });
    } catch (e) {
      print("Failed to get app usage: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchAppUsage();
  }

  String _getEncouragementMessage(double completionRate) {
    if (completionRate == 1.0) {
      return '모든 To Do를 완료했어요!';
    } else if (completionRate >= 0.75) {
      return 'To Do를 거의 완료했어요!';
    } else if (completionRate >= 0.5) {
      return '잘하고 있어요! 킵고잉~';
    } else {
      return '오늘도 할 수 있어요, 파이팅!';
    }
  }

  Widget _percentCard(double percent, String mesage) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
      ),
      width: 1000,
      height: 50,
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                flex: (percent * 100).toInt(),
                child: Container(
                  color: Color(0xFFBCF1AF),
                ),
              ),
              Expanded(
                flex: 100,
                child: Container(
                  color: Color(0xFFE3E3E3),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(width: 10),
                Wrap(
                  children: [Font(mesage, 'M')],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<double>(
        future: _fetchCompletionRate(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            double completionRate = snapshot.data ?? 0.0;

            // 전체 사용 시간 계산
            int phoneUsingTime = appList.fold(0, (sum, app) => sum + app.usingTime);

            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: AnalogClock(),
                    ),
                  ),
                ),
                _percentCard(phoneUsingTime / (24 * 60), '오늘 휴대폰 사용시간: ${phoneUsingTime ~/ 60}h ${phoneUsingTime % 60}m'),
                SizedBox(height: 10),
                _percentCard(completionRate, 'To Do 달성도: ${(completionRate * 100).toStringAsFixed(1)}%'),
                SizedBox(height: 5),
                Font(_getEncouragementMessage(completionRate), 'M', bold: true),
                SizedBox(height: 50),
              ],
            );
          }
        },
      ),
    );
  }
}
