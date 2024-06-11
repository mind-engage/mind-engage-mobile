import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'quiz_page.dart';
import 'url_provider.dart';

class TopicsPage extends StatefulWidget {
  final List<dynamic> topics;
  final String sessionId;
  const TopicsPage({super.key, required this.sessionId, required this.topics});

  @override
  _TopicsPageState createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {

  void navigateToQuiz(int topicId) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizPage(sessionId: widget.sessionId, topicId: topicId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
      ),
      body: ListView.separated(
        itemCount: widget.topics.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 8.0),
            child: ListTile(
              title: Text(widget.topics[index]['topic_title']),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => navigateToQuiz(widget.topics[index]['topic_id']),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              hoverColor: Colors.blue.shade100,
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(),
      ),
    );
  }
}