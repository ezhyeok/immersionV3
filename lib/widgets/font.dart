import 'package:flutter/cupertino.dart';

Widget backgroundFont(String text, String font) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
    decoration: BoxDecoration(
      color: Color(0xFFBCF1AF),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Font(text, font, bold: true),
  );
}

Widget Font(String text, String font, {int highlight = -1, Color clr = const Color(0xFF000000), bool bold = false}) {
  double size = 0;

  if (highlight == 0) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Font(text, font, clr: clr),
    );
  } else if (highlight == 1) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: BoxDecoration(
        color: Color(0xFFE3E3E3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Font(text, font, clr: clr),
    );
  } else if (highlight == 2) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
      decoration: BoxDecoration(
        color: Color(0xFFBCF1AF),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Font(text, font, clr: clr),
    );
  }

  var weight = bold ? FontWeight.bold : FontWeight.normal;
  if (font == "XL") size = 24;
  else if (font == "L") size = 20;
  else if (font == "M") size = 16;
  else if (font == "S") size = 12;
  return Text(text, style: TextStyle(fontSize: size, color: clr, fontWeight: weight), textAlign: TextAlign.center);
}