import 'dart:math';

import 'package:comt/widgets/listViewBuilder.dart';
import 'package:flutter/material.dart';
import '../widgets/font.dart';
import '../widgets/problemCard.dart';
import 'package:comt/model/home_model.dart';
import 'package:comt/model/pick_model.dart'; // PickApiService 및 PickData 가져오기

class PicksPage extends StatefulWidget {
  @override
  _PicksPageState createState() => _PicksPageState();
}

class _PicksPageState extends State<PicksPage> {
  late List<List<dynamic>> _pick_problems;
  late String _least_tag;
  late List<List<dynamic>> _least_tag_problems;
  late String _most_tag;
  late List<List<dynamic>> _most_tag_problems;

  bool _isLoading = true;

  final PickApiService apiService = PickApiService(); // PickApiService 인스턴스 생성

  @override
  void initState() {
    super.initState();
    _fetchPickData();
  }

  Future<void> _fetchPickData() async {
    try {
      PickData pickData = await apiService.fetchPickData();
      setState(() {
        _pick_problems = pickData.pick_problems;
        _least_tag = pickData.least_tag;
        _least_tag_problems = pickData.least_tag_problems;
        _most_tag = pickData.most_tag;
        _most_tag_problems = pickData.most_tag_problems;

        _isLoading = false;

        print('테스트 ${_pick_problems}');
      });
    } catch (e) {
      print('Failed to load pick data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    double _runSpace = 5;
    double _contentsSpace = 30;
    double _lineSpace = 10;
    List<Widget> todo = [];

    todo.add(SizedBox(height: _lineSpace,));

    todo.add(Wrap(alignment: WrapAlignment.start, runSpacing: _runSpace, children: [SizedBox(width: 5), Font("티어 기반 추천 문제예요", 'XL', bold: true)]),);
    todo.add(SizedBox(height: _lineSpace,));
    todo.addAll(_makeProblemCards(_pick_problems));
    todo.add(SizedBox(height: _contentsSpace,));

    todo.add(Wrap(alignment: WrapAlignment.start, runSpacing: _runSpace, children: [SizedBox(width: 5), backgroundFont('#' + _least_tag, 'XL'), Font(" 공부는 어떤가요?", 'XL', bold: true)]),);
    todo.add(SizedBox(height: _lineSpace,));
    todo.addAll(_makeProblemCards(_least_tag_problems));
    todo.add(SizedBox(height: _contentsSpace,));

    todo.add(Wrap(alignment: WrapAlignment.start, runSpacing: _runSpace, children: [SizedBox(width: 5), Font("도전적인 ", 'XL', bold: true), backgroundFont('#' + _most_tag, 'XL'), Font(" 문제예요", 'XL', bold: true)]),);
    todo.add(SizedBox(height: _lineSpace,));
    todo.addAll(_makeProblemCards(_most_tag_problems));
    todo.add(SizedBox(height: _lineSpace,));

    return listViewBuilder(todo);
  }

  List<Widget> _makeProblemCards(List<List<dynamic>> problems, {double runSpace = 5}) {
    List<Widget> ret = [];
    for (int i = 0; i < min(3, problems.length); i++) {
      var problem = problems[i];
      ret.add(problemCard(problem[0].toString(), problem[1], problem[2], problem[3]));
      ret.add(SizedBox(height: runSpace,));
    }
    if (problems.isEmpty) {
      ret.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(width: 1.5, color: Color(0xFFE3E3E3)),
              ),
              color: Color(0xFFFFFFFF),
              child: ListTile(
                title: Font('추천 문제가 없어요.', 'M'),
              ),
            ),
          )
      );
    }
    return ret;
  }
}