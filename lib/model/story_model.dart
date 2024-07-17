import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class Post {
  final String id;
  final String problemNum;
  final String codeURL;
  final String content;
  final String result;
  final String authorId;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.problemNum,
    required this.codeURL,
    required this.content,
    required this.result,
    required this.authorId,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      problemNum: json['problemNum'],
      codeURL: json['codeURL'],
      content: json['content'],
      result: json['result'],
      authorId: json['author_id'],
      comments: (json['comments'] as List).map((i) => Comment.fromJson(i)).toList(),
    );
  }
}

class Comment {
  final String id;
  final String content;
  final String postId;
  final String authorId;

  Comment({
    required this.id,
    required this.content,
    required this.postId,
    required this.authorId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      content: json['content'],
      postId: json['post_id'],
      authorId: json['author_id'],
    );
  }
}


class StoryApiService {
  static const String baseUrl = 'http://192.168.227.4:8080';

  Future<List<Post>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      List<dynamic> posts = body['posts'];

      return posts.map((dynamic item) => Post.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> postComment(String postId, String content) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    final response = await http.post(
      Uri.parse('$baseUrl/comments/$postId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to post comment');
    }
  }
}