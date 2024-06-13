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

  void navigateToQuiz(int topicId, String topicTitle) async {
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
        lectureName: widget.lectureTitle, // Use lectureName for clarity
      ),
      body: ListView.separated(
        itemCount: widget.topics.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 16, // Indented divider
          thickness: 0.8, // Slightly thicker divider
        ),
        itemBuilder: (context, index) {
          return InkWell( // Add InkWell for tap feedback
            onTap: () => navigateToQuiz(widget.topics[index]['topic_id'], widget.topics[index]['topic_title']),
            child: Container(
              color: Colors.transparent, // For ripple effect
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Text(
                    widget.topics[index]['topic_title'],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 20),
              ),
            ),
          );
        },
      ),
    );
  }
}