import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'quiz_page.dart';
import 'url_provider.dart';
import 'custom_app_bar.dart';

class TopicsPage extends StatefulWidget {
  final List<dynamic> topics;
  final String sessionId;
  final String lectureTitle;
  const TopicsPage({super.key, required this.sessionId, required this.topics, required this.lectureTitle});

  @override
  _TopicsPageState createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {

  void navigateToQuiz(int topicId, topicTitle) async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizPage(sessionId: widget.sessionId, topicId: topicId, topicTitle: topicTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Topics',
        topicName: widget.lectureTitle
      ),
      body: ListView.separated(
        itemCount: widget.topics.length,
        separatorBuilder: (context, index) => const Divider(height: 0), // Use Divider for better visual separation
        itemBuilder: (context, index) {
          return ListTile(
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Add padding to the title
              child: Text(
                widget.topics[index]['topic_title'],
                style: const TextStyle(fontSize: 18), // Increase font size
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 20), // Use a larger arrow icon
            onTap: () => navigateToQuiz(widget.topics[index]['topic_id'], widget.topics[index]['topic_title']),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          );
        },
      ),
    );
  }
}