import 'package:comt/UserData.dart';
import 'package:flutter/material.dart';
import '../widgets/font.dart';
import '../widgets/listViewBuilder.dart';
import 'package:http/http.dart' as http;
import 'package:comt/config.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:app_usage/app_usage.dart';

class Todo {
  String id;
  bool valid;
  bool star;
  String todoId;

  Todo(this.id, this.valid, this.star, this.todoId);
}

class todoPage extends StatefulWidget {
  const todoPage({super.key});

  @override
  State<todoPage> createState() => _todoPageState();
}

class _todoPageState extends State<todoPage> {
  List<Todo> todoList = [];
  bool isLoading = true; // 로딩 상태 변수 추가
  final TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTodoList();
  }

  Future<void> _fetchTodoList() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}getTodoSort?uniqueId=${UserData.instance.uniqueId}&date=${DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        print('서버 오류');
      } else {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          todoList = data.map((item) => Todo(
              item['id'],
              item['valid']==1,
              item['star']==1,
              item['todoId'].toString()
          )).toList();
        });
      }
    } catch (e) {
      print('Error fetching todo list: $e');
    } finally {
      setState(() {
        isLoading = false; // 데이터 로드 완료 후 로딩 상태 해제
      });
    }
  }

  void _addTodo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('To Do 추가'),
          content: TextField(
            controller: _todoController,
            decoration: InputDecoration(hintText: "To Do를 입력하세요"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                _todoController.clear();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('추가'),
              onPressed: () async {
                try {
                  final response = await http.post(
                    Uri.parse('${Config.baseUrl}addTodo'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'uniqueId': UserData.instance.uniqueId,
                      'id': _todoController.text,
                    }),
                  );
                  if (response.statusCode != 200) {
                    print('Todo 전송에 오류가 발생했습니다.');
                  } else {
                    setState(() {
                      _fetchTodoList();
                      //todoList.add(Todo(_todoController.text, true, false));
                    });
                    _todoController.clear();
                    Navigator.of(context).pop();
                  }
                } catch (e) {
                  print('Error adding todo: $e');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _todoCard(Todo x) {
    return Row(
      children: [
        IconButton(
          icon: x.valid ? Icon(Icons.check_box_outlined) : Icon(Icons.check_box),
          color: x.valid ? Color(0xFF000000) : Color(0xFF8D8D8D),
          onPressed: () async {
            try {
              final response = await http.post(
                Uri.parse('${Config.baseUrl}toggleValid'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'todoId': x.todoId
                }),
              );
              if (response.statusCode != 200) {
                print('Toggle 전송에 오류가 발생했습니다.');
              } else {
                setState(() {
                  x.valid = !x.valid;
                });
              }
            } catch (e) {
              print('Error adding toggle: $e');
            }
          },
        ),
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            runSpacing: 5,
            children: [
              x.valid
                  ? Font(x.id, 'M', highlight: (x.star ? 2 : 1))
                  : Font(x.id, 'M', highlight: 0, clr: Color(0xFF8D8D8D)),
            ],
          ),
        ),
        IconButton(
          icon: x.star ? Icon(Icons.star) : Icon(Icons.star_border),
          color: x.valid ? Color(0xFF000000) : Color(0xFF8D8D8D),
          onPressed: () async {
            try {
              final response = await http.post(
                Uri.parse('${Config.baseUrl}toggleStar'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'todoId': x.todoId
                }),
              );
              if (response.statusCode != 200) {
                print('Todo 전송에 오류가 발생했습니다.');
              } else {
                setState(() {
                  x.star = !x.star;
                });
              }
            } catch (e) {
              print('Error adding todo: $e');
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double _runSpace = 5;
    double _contentsSpace = 30;
    double _lineSpace = 10;
    List<Widget> printing = [];

    printing.add(SizedBox(height: _lineSpace));

    for (int i = 0; i < todoList.length; i++) {
      printing.add(_todoCard(todoList[i]));
    }
    if (todoList.isEmpty) {
      printing.add(
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 5,
            children: [Font('TODO를 추가해주세요', 'M', highlight: 1),],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,

      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              child: Font('TODO', 'XL', bold: true),
            ),
            Expanded(child: listViewBuilder(printing)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Color(0xFF4BA933),
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}