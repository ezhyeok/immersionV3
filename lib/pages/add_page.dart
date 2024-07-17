import 'package:flutter/material.dart';
import '../model/story_model.dart';
import '../model/post_model.dart';

class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _problemNumberController = TextEditingController();
  final _codeLinkController = TextEditingController();
  final _contentController = TextEditingController();
  final PostApiService apiService = PostApiService(); // ApiService 인스턴스 생성

  String _selectedStatus = 'AC';
  final List<String> _statuses = ['AC', 'WA', 'TLE', 'MLE', 'RE', 'CE', '질문'];

  @override
  void dispose() {
    _problemNumberController.dispose();
    _codeLinkController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('입력 오류'),
          content: Text(message),
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

  Future<void> _storySubmit() async {
    if (_problemNumberController.text.isEmpty) {
      _showValidationError('문제 번호를 입력하세요.');
      return;
    }

    if (int.tryParse(_problemNumberController.text) == null) {
      _showValidationError('문제 번호는 숫자여야합니다.');
      return;
    }
    if (_codeLinkController.text.isEmpty) {
      _showValidationError('코드 링크를 입력하세요.');
      return;
    }
    if (_contentController.text.isEmpty) {
      _showValidationError('내용을 입력하세요.');
      return;
    }

    // 입력된 값들을 JSON으로 변환
    PostData postData = PostData(
      problemNum: _problemNumberController.text,
      result: _selectedStatus,
      codeURL: _codeLinkController.text,
      content: _contentController.text,
    );

    try {
      await apiService.submitPost(postData);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('게시 완료!'),
          );
        },
      );

      Future.delayed(Duration(milliseconds: 850), () {
        Navigator.of(context).pop();
        Navigator.of(context).pop(true);
      });
    } catch (e) {
      _showValidationError('게시 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '/<Alquerithm>',
          style: TextStyle(
            color: Color(0xFFFFA423),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Color(0xFFFFA423),
            height: 2.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _problemNumberController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      hintText: '문제 번호 입력',
                    ),
                  ),
                ),
                SizedBox(width: 6),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF49454F)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                      items: _statuses.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedStatus = newValue!;
                        });
                      },
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      dropdownColor: Colors.white,
                      isDense: true,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _codeLinkController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                hintText: '코드 링크 입력',
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '내용을 입력하세요',
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '취소',
                    style: TextStyle(color: Color(0xFF49454F)),
                  ),
                ),
                ElevatedButton(
                  onPressed: _storySubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF49454F),
                  ),
                  child: Text(
                    '게시하기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}