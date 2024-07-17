// lib/pages/my_story_page.dart
import 'package:flutter/material.dart';
import '../widgets/font.dart';
import '../widgets/listViewBuilder.dart';

// Post class
class Post2 {
  int problemNum = 1111;
  String problemTitle = '으에에';
  String result = '??';
  int tier = 0;

  Post2(int problemNum, String problemTitle, String result, int tier) {
    this.problemNum = problemNum;
    this.problemTitle = problemTitle;
    this.result = result;
    this.tier = tier;
  }
}

class MyStoryPage extends StatefulWidget {
  const MyStoryPage({super.key});
  @override
  State<MyStoryPage> createState() => _MyStoryPageState();
}

class _MyStoryPageState extends State<MyStoryPage> {
  @override
  Widget build(BuildContext context) {
    List<Post2> myStory = [];
    List<Post2> likedStory = [];
    List<Post2> commentedStory = [];

    for (int i = 0; i < 10; i++) {
      myStory.add(Post2(1000 + i, 'A+B', 'AC', i));
      likedStory.add(Post2(1010 + i, 'A+B', 'AC', i));
      commentedStory.add(Post2(1020 + i, 'A+B', 'AC', i));
    }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('My Story Page', style: TextStyle(color: Colors.white,),),
          backgroundColor: Color(0xFFFFA423),
        ),
        body: Center(
          child: Column(
            children: [
              Expanded(child: _storyListViewBuilder('내 Story', myStory, '아직 Story를 작성하지 않았어요.'),),
              //SizedBox(height: 10,),
              Expanded(child: _storyListViewBuilder('북마크한 Story', likedStory, '아직 북마크한 Story가 없어요.'),),
              //SizedBox(height: 10,),
              Expanded(child: _storyListViewBuilder('댓글을 남긴 Story', commentedStory, '아직 Story에 댓글을 남기지 않았어요.'),),
              SizedBox(height: 10,),
            ]
          ),
        )
    );
  }
}

Widget _storyListViewBuilder(String title, List<Post2> story, String errorMessage) {
  Widget temp;
  if (story.isEmpty) {
    temp = Card(
      color: Color(0xFFE3E3E3),
      child: ListTile(
        title: Font(errorMessage, 'M'),
      ),
    );
  } else {
    temp = ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      itemCount: story.length,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Color(0xFFE3E3E3),
          child: ListTile(
            title: Text("${story[index].problemNum}번: ${story[index].problemTitle}"),
            subtitle: Text("${story[index].result}"),
            trailing: Image.asset('assets/img/${story[index].tier}.png'),
          ),
        );
      },
    );
  }
  return Container(
    height: 1000,
    child: Column(
      children: [
        Expanded(flex: 1, child: Container(alignment: Alignment.centerLeft, margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15), child: Font(title, 'L'))),
        Expanded(flex: 4, child: temp),
      ],
    ),
  );
}