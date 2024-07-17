import 'package:comt/pages/stop_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:flutter/widgets.dart';
import 'package:pie_chart/pie_chart.dart';  // pie_chart 패키지 추가
import '../widgets/font.dart';
import '../widgets/listViewBuilder.dart';

class app {
  String id;
  int usingTime;

  app(this.id, this.usingTime);
}

class analysisPage extends StatefulWidget {
  const analysisPage({super.key});

  @override
  State<analysisPage> createState() => _analysisPageState();
}

class _analysisPageState extends State<analysisPage> {
  late List<app> appList = [];
  Map<String, double> dataMap = {};

  @override
  void initState() {
    super.initState();
    _fetchUsageStats();
  }

  Future<void> _fetchUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day); // 오늘의 시작 시간
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);

      setState(() {
        appList = infoList
            .where((info) => info.usage.inMinutes > 0) // 0분 사용한 앱 제외
            .map((info) => app(info.appName, info.usage.inMinutes))
            .toList();

        appList.sort((a, b) => b.usingTime.compareTo(a.usingTime)); // 사용 시간 많은 순으로 정렬
        // 전체 사용 시간 계산
        int totalUsageTime = appList.fold(0, (sum, app) => sum + app.usingTime);

        // 파이차트 데이터 생성 (퍼센트로 변환)
        dataMap = {
          for (var app in appList) app.id: (app.usingTime / totalUsageTime * 100).toDouble()
        };
      });
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  Widget _buildPieChart() {
    return Container(
      //height: MediaQuery.of(context).size.height * 0.4,
      padding: EdgeInsets.all(16),
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 3.2,
        colorList: [Colors.blue, Colors.green, Colors.red, Colors.yellow, Colors.purple, Colors.orange],
        initialAngleInDegree: 0,
        chartType: ChartType.disc,
        ringStrokeWidth: 32,
        centerText: "Usage",
        legendOptions: LegendOptions(
          showLegendsInRow: false,
          legendPosition: LegendPosition.right,
          showLegends: true,
          legendTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: true,
          showChartValues: true,
          showChartValuesInPercentage: false,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
      ),
    );
  }

  Widget _analysisCard(app x) {
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
              Expanded(flex: x.usingTime, child: Container(color: Color(0xFFBCF1AF),)),
              Expanded(flex: 24 * 60 - x.usingTime, child: Container(color: Color(0xFFE3E3E3),)),
            ],
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                SizedBox(width: 10,),
                Wrap(children: [Font('${x.id} (${x.usingTime ~/ 60}h ${x.usingTime % 60}m)', 'M'),],),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double _runSpace = 5;
    double _contentsSpace = 30;
    double _lineSpace = 10;
    List<Widget> printing = [];

    printing.add(SizedBox(height: _lineSpace,));
    for (int i = 0; i < appList.length; i++) {
      printing.add(_analysisCard(appList[i]));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          height: 600,
          child: Column(
            children: [
              Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Font('앱 사용 시간', 'XL', bold: true)
              ),
              _buildPieChart(),
              Expanded(
                child: listViewBuilder(printing),
              ),

            ],
        ),
        ),
    );
  }
}
