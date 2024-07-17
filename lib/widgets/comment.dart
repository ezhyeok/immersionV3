// widgets/comment_card.dart
import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  final String text;
  final String writer;

  const CommentCard({
    required this.text,
    required this.writer,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      color: Color(0xFFFFF1DE),
      child: ListTile(
        leading: Icon(Icons.person),
        title: Text(text),
      ),
    );
  }
}