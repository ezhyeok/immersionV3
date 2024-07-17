import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';

void showToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Color(0xFF49454F),
    textColor: Color(0xFFFFFFFF),
    fontSize: 16,
    toastLength: Toast.LENGTH_SHORT,
  );
}