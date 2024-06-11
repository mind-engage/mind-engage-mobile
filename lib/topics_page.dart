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

  void fetchQuizAndNavigate(int topicId) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/quiz?session_id=${widget.sessionId}&topic_id=$topicId'); // Adjust the URL as needed
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var quizData = jsonDecode(response.body);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizPage(sessionId: widget.sessionId, topicId: topicId),
        ),
      );
    } else {
      // Handle error or show an alert/message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch quiz for the selected topic.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
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
              onTap: () => fetchQuizAndNavigate(widget.topics[index]['topic_id']),
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