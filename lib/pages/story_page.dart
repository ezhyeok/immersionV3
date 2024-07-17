import 'package:flutter/material.dart';
import '../model/story_model.dart';
import '../widgets/comment.dart';
import 'add_page.dart';
import 'my_story_page.dart';

class StoryPage extends StatefulWidget {
  @override
  _StoryPageState createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  bool _isBookmarked = false;
  bool _showAdditionalButtons = false;
  int _currentIndex = 0;
  List<Post> _posts = [];
  bool _isLoading = true;
  final TextEditingController _commentController =
      TextEditingController(); // 댓글 입력 컨트롤러 추가

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    StoryApiService apiService = StoryApiService();
    try {
      List<Post> posts = await apiService.fetchPosts();
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      // Handle the error appropriately
      print("Error fetching posts: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPage()),
    );

    if (result == true) {
      _fetchPosts();
    }
  }

  Future<void> _navigateToMyStoryPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyStoryPage()),
    );

    if (result == true) {
      _fetchPosts();
    }
  }

  Future<void> _postComment() async {
    if (_commentController.text.isEmpty) {
      // 입력된 댓글이 없으면 경고 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('입력 오류'),
            content: Text('댓글을 입력하세요.'),
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
      return;
    }

    try {
      await StoryApiService()
          .postComment(_posts[_currentIndex].id, _commentController.text);
      _commentController.clear(); // 댓글 입력 필드 초기화
      _fetchPosts(); // 댓글 등록 후 게시물 다시 불러오기
    } catch (e) {
      // 댓글 전송 실패 시 처리
      print("Error posting comment: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('오류'),
            content: Text('댓글 등록 중 오류가 발생했습니다. 다시 시도해주세요.'),
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
  }

  void _nextPost() {
    if (_currentIndex < _posts.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousPost() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 북마크
                      IconButton(
                        icon: Icon(
                          _isBookmarked
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: Color(0xFFFFA423),
                        ),
                        onPressed: () {
                          setState(() {
                            _isBookmarked = !_isBookmarked;
                          });
                        },
                      ),

                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back,
                                color: _currentIndex > 0
                                    ? Colors.black
                                    : Colors.grey),
                            onPressed: _previousPost,
                          ),
                          Text(
                            _posts.isNotEmpty
                                ? '${_posts[_currentIndex].problemNum} [${_posts[_currentIndex].result}]'
                                : '',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward,
                                color: _currentIndex < _posts.length - 1
                                    ? Colors.black
                                    : Colors.grey),
                            onPressed: _nextPost,
                          ),
                        ],
                      ),

                      // 햄버거 버튼
                      IconButton(
                        icon: Icon(Icons.menu, color: Color(0xFFFFA423)),
                        onPressed: () {
                          setState(() {
                            _showAdditionalButtons = !_showAdditionalButtons;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // SingleChildScrollView 적용
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 게시글
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : _posts.isNotEmpty
                                ? Container(
                                    margin: EdgeInsets.all(16.0),
                                    padding: EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xFFFFA423), width: 2.0),
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.person),
                                        SizedBox(width: 8.0),
                                        Expanded(
                                          child: Text(
                                            _posts[_currentIndex].content,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                        '첫 게시글 주인공이시군요! 주소를 알려주면 선물을 드립니다!')),

                        // 댓글창
                        _posts.isNotEmpty
                            ? Column(
                                children: _posts[_currentIndex]
                                    .comments
                                    .map((comment) {
                                  return CommentCard(
                                    text: comment.content,
                                    writer: comment.authorId, // 작성자 이름으로 변경 필요
                                  );
                                }).toList(),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),

                // 댓글 입력창을 하단에 고정
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFFFF1DE),
                        child: Icon(Icons.person, color: Color(0xFFFFA423)),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: TextField(
                          controller: _commentController, // 댓글 입력 컨트롤러 연결
                          decoration: InputDecoration(
                            hintText: '댓글을 입력하세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.0),
                              borderSide: BorderSide(color: Color(0xFF49454F)),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        icon: Icon(Icons.send, color: Color(0xFF49454F)),
                        onPressed: _postComment, // 댓글 전송 로직 호출
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _showAdditionalButtons
                ? Positioned(
                    right: 15,
                    top: 70,
                    child: Column(
                      children: [
                        _buildAdditionalButton(Icons.add, _navigateToAddPage),
                        _buildAdditionalButton(
                            Icons.person, _navigateToMyStoryPage),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  // 우상단 햄버거 버튼
  Widget _buildAdditionalButton(IconData icon, Function onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: FloatingActionButton(
        onPressed: () {
          onPressed();
        },
        backgroundColor: const Color(0xFFFFA423),
        foregroundColor: Colors.white,
        child: Icon(icon),
      ),
    );
  }
}
