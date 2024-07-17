import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'font.dart';

Widget problemCard(String problemNum, String title, int problemSolveNum, int level) {
  int integerNum = int.parse(problemNum);
  bool problemSolved = (integerNum % 2 == 0);
  return Card(
// color: problemSolved ? Color(0xFFDEFFDE) : Color(0xFFE3E3E3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(width: 1.5, color: Color(0xFFE3E3E3)),
    ),
    color: Color(0xFFFFFFFF),

    child: ListTile(
      title: Wrap(alignment: WrapAlignment.start,
          runSpacing: 5,
          children: [Font("$problemNum번: $title", 'M')]),
      subtitle: Wrap(alignment: WrapAlignment.start,
          runSpacing: 5,
          children: [Font("$problemSolveNum명이 풀었어요", 'S')]),
      trailing: Image.asset('assets/img/$level.png'),
    ),
  );
}
