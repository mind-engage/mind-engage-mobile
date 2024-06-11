import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'url_provider.dart';

class QuizPage extends StatefulWidget {
  final String sessionId;
  final int topicId;
  const QuizPage({super.key, required this.sessionId, required this.topicId});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int level = 0; // Initialize with the basic level
  Map<String, dynamic> quizData = {};
  bool _isLoading = false; // Initialize loading state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchQuiz(level);
    });
  }

  void fetchQuiz(int lvl) async {
    setState(() {
      _isLoading = true; // Set loading to true
    });
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/quiz?session_id=${widget.sessionId}&topic_id=${widget.topicId}&level=$lvl');
    var response = await http.get(url);
    setState(() {
      _isLoading = false; // Set loading to false
      if (response.statusCode == 200) {
        quizData = jsonDecode(response.body);
        level = lvl; // Update the current level
      } else {
        Fluttertoast.showToast(
            msg: "Failed to fetch quiz data.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    });
  }

  void showCongratulationsPopup() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You have completed the highest level of the quiz.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Exit the quiz page
              },
            ),
          ],
        );
      },
    );
  }

  void _submitAnswer(int? selectedIndex) async {
    if (selectedIndex == null) {
      Fluttertoast.showToast(
          msg: "Please select an answer before submitting.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    setState(() {
      _isLoading = true; // Set loading to true
    });
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/submit_answer');
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': widget.sessionId,
          'topic_id': widget.topicId,
          'level': level,
          'answer': selectedIndex,
        }));
    setState(() {
      _isLoading = false; // Set loading to false
    });
    var data = jsonDecode(response.body);
    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );

    // If answer is correct and level is not maximum, increment level or show congratulations
    if (data['result'] == 'true') {
      if (level < 2) {
        fetchQuiz(level + 1);
      } else {
        showCongratulationsPopup();
      }
    } else {
      fetchConceptualClarity(widget.topicId, level, selectedIndex);
    }
  }

  void fetchConceptualClarity(int topicId, int level, int? answer) async {
    setState(() {
      _isLoading = true; // Indicate loading while fetching data
    });
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/conceptual_clarity?session_id=${widget.sessionId}&topic_id=$topicId&level=$level&answer=$answer');
    var response = await http.get(url);
    setState(() {
      _isLoading = false; // Reset loading indicator after fetch
    });
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Conceptual Clarity'),
            content: SingleChildScrollView(
              child: Text(data['concept'], style: TextStyle(height: 1.5)),
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
          fontSize: 16.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> choices = List<String>.from(quizData['choices'] ?? []);
    String question = quizData['question'] ?? "No question available";
    String summary = quizData['summary'] ?? "No summary available";

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Details - ${['Basic', 'Intermediate', 'Advanced'][level]}'),
        actions: [
          PopupMenuButton<int>(
            onSelected: fetchQuiz,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 0, child: Text('Basic')),
                PopupMenuItem(value: 1, child: Text('Intermediate')),
                PopupMenuItem(value: 2, child: Text('Advanced')),
              ];
            },
          ),
        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : buildQuizContent(choices, question, summary),
    );
  }

  Widget buildQuizContent(List<String> choices, String question, String summary) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Summary: $summary', style: Theme.of(context).textTheme.bodyLarge),
            SizedBox(height: 20),
            Text('Question: $question', style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 20),
            Text('Choose your answer:', style: Theme.of(context).textTheme.titleLarge),
            ...choices.asMap().entries.map((entry) {
              int idx = entry.key;
              String choice = entry.value;
              return ListTile(
                title: Text(choice),
                leading: Radio<int>(
                  value: idx,
                  groupValue: quizData['selectedChoice'],
                  onChanged: (int? value) {
                    setState(() {
                      quizData['selectedChoice'] = value;
                    });
                  },
                ),
              );
            }).toList(),
            ElevatedButton(
              onPressed: () => _submitAnswer(quizData['selectedChoice']),
              child: const Text('Submit Answer'),
            ),
          ],
        ),
      ),
    );
  }
}