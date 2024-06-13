import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'url_provider.dart';
import 'custom_app_bar.dart'; // Import the custom app bar

class QuizPage extends StatefulWidget {
  final String sessionId;
  final int topicId;
  final String topicTitle;
  const QuizPage({super.key, required this.sessionId, required this.topicId, required this.topicTitle});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int level = 0;
  Map<String, dynamic> quizData = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchQuiz(level);
    });
  }

  void fetchQuiz(int lvl) async {
    setState(() {
      _isLoading = true;
    });
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/quiz?session_id=${widget.sessionId}&topic_id=${widget.topicId}&level=$lvl');
    var response = await http.get(url);
    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        quizData = jsonDecode(response.body);
        level = lvl;
      } else {
        Fluttertoast.showToast(
          msg: "Failed to fetch quiz data.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  void showCongratulationsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have completed the highest level of the quiz.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAnswer(int? selectedIndex) async {
    if (selectedIndex == null) {
      Fluttertoast.showToast(
        msg: "Please select an answer before submitting.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/submit_answer');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'session_id': widget.sessionId,
        'topic_id': widget.topicId,
        'level': level,
        'answer': selectedIndex,
      }),
    );
    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      if (data['result'] == 'true') {
        if (level < 2) {
          fetchQuiz(level + 1);
        } else {
          showCongratulationsPopup();
        }
      } else {
        fetchConceptualClarity(widget.topicId, level, selectedIndex);
      }
    } else {
      // Handle error from the backend
      Fluttertoast.showToast(
        msg: "Failed to submit answer. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }


  void fetchConceptualClarity(int topicId, int level, int? answer) async {
    setState(() {
      _isLoading = true;
    });
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse(
        '$baseUrl/conceptual_clarity?session_id=${widget.sessionId}&topic_id=$topicId&level=$level&answer=$answer');
    var response = await http.get(url);
    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Conceptual Clarity'),
            content: SingleChildScrollView(
              child: Text(data['concept'], style: const TextStyle(height: 1.5)),
            ),
            actions: [
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to fetch conceptual clarity.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> choices = List<String>.from(quizData['choices'] ?? []);
    String question = quizData['question'] ?? "No question available";
    String summary = quizData['summary'] ?? "No summary available";

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quiz - ${['Basic', 'Intermediate', 'Advanced'][level]}',
        actions: [
          PopupMenuButton<int>(
            onSelected: fetchQuiz,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: 0, child: Text('Basic')),
                const PopupMenuItem(value: 1, child: Text('Intermediate')),
                const PopupMenuItem(value: 2, child: Text('Advanced')),
              ];
            },
          ),
        ],
        topicName: widget.topicTitle,    // Pass the topic name
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildQuizContent(choices, question, summary),
    );
  }

  Widget buildQuizContent(List<String> choices, String question, String summary) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Summary: $summary',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Question: $question',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Choose your answer:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ...choices.asMap().entries.map((entry) {
              int idx = entry.key;
              String choice = entry.value;
              return RadioListTile<int>(
                value: idx,
                groupValue: quizData['selectedChoice'],
                onChanged: (int? value) {
                  setState(() {
                    quizData['selectedChoice'] = value;
                  });
                },
                title: Text(choice),
                // Other properties of RadioListTile for styling, etc.
              );
            }).toList(),
            const SizedBox(height: 20), // Spacing
            Center( // Center the button
              child: ElevatedButton(
                onPressed: () => _submitAnswer(quizData['selectedChoice']),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Submit Answer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}