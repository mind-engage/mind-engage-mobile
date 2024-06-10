import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MindEngageApp());
}

class BaseUrlProvider extends InheritedWidget {
  final String baseUrl;

  const BaseUrlProvider({
    super.key,
    required super.child,
    required this.baseUrl,
  });

  static BaseUrlProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BaseUrlProvider>();
  }

  @override
  bool updateShouldNotify(BaseUrlProvider oldWidget) {
    return baseUrl != oldWidget.baseUrl;
  }
}

class MindEngageApp extends StatelessWidget {
  const MindEngageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseUrlProvider(
      baseUrl: 'http://192.168.0.140:8080',  // Your base URL
      child: MaterialApp(
        title: 'MindEngage',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sessionId = "";
  List<dynamic> lectures = [];
  List<dynamic> topics = [];
  Map<String, dynamic>? quiz;
  //String baseUrl = 'http://192.168.0.140:8080'; // Change to your server's IP address if needed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerSession();
    });
  }

  void registerSession() async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/register');
    var response = await http.post(url);
    var data = jsonDecode(response.body);
    setState(() {
      _sessionId = data['session_id'];
    });
  }

  void fetchLectures() async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/lectures?session_id=$_sessionId');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      lectures = data;
    });
  }

  void fetchTopics(String lectureId) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/topics?lecture_id=$lectureId&session_id=$_sessionId');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      topics = data;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicsPage(sessionId: _sessionId, topics: topics),
      ),
    );
  }
/*
  void submitAnswer(String topicId, String userAnswer) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/submit_answer');
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': _sessionId,
          'topic_id': topicId,
          'answer': userAnswer,
        }));
    var data = jsonDecode(response.body);
    Fluttertoast.showToast(
        msg: data['result'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
    if (data['result'] != 'Correct!') {
      fetchConceptualClarity(topicId);
    }
  }
*/
  void fetchConceptualClarity(String topicId) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/conceptual_clarity?topic_id=$topicId&session_id=$_sessionId&answer=a');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conceptual Clarity'),
          content: SingleChildScrollView(
            child: Text(data['concept'], style: TextStyle(height: 1.5)), // Enhanced for better readability
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MindEngage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: fetchLectures,
              child: const Text('Load Lectures'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: lectures.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(lectures[index]['lecture_title']),
                    onTap: () => fetchTopics(lectures[index]['lecture_id'].toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class TopicsPage extends StatefulWidget {
  final List<dynamic> topics;
  final String sessionId;
  const TopicsPage({super.key, required this.sessionId, required this.topics});

  @override
  _TopicsPageState createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {

  void fetchQuizAndNavigate(String topicId) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/quiz?session_id=${widget.sessionId}&topic_id=$topicId'); // Adjust the URL as needed
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var quizData = jsonDecode(response.body);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QuizPage(sessionId: widget.sessionId, quizData: quizData),
        ),
      );
    } else {
      // Handle error or show an alert/message
      print('Failed to fetch quiz');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
      ),
      body: ListView.builder(
        itemCount: widget.topics.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.topics[index]['topic_title']),
            onTap: () => fetchQuizAndNavigate(widget.topics[index]['topic_id'].toString()),
          );
        },
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final Map<String, dynamic> quizData;
  final String sessionId;
  const QuizPage({Key? key, required this.sessionId, required this.quizData}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int? _selectedChoiceIndex;

  void _submitAnswer() async {
    if (_selectedChoiceIndex == null) {
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

    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    int topicId = widget.quizData['topic_id'];
    int level = widget.quizData['level'];

    var url = Uri.parse('$baseUrl/submit_answer');
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': widget.sessionId, // Update with actual session id
          'topic_id': topicId,
          'level': level,
          'answer': _selectedChoiceIndex,
        }));
    var data = jsonDecode(response.body);

    Fluttertoast.showToast(
        msg: data['message'],
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );

    if (data['result'] != 'true') {
      fetchConceptualClarity(topicId, level, _selectedChoiceIndex);
    }
  }

  void fetchConceptualClarity(int topicId, int level, int? answer) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/conceptual_clarity?session_id=${widget.sessionId}&topic_id=$topicId&level=$level&level=level&answer=$answer');  // Update with actual session id
    var response = await http.get(url);
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
  }

  @override
  Widget build(BuildContext context) {
    List<String> choices = List<String>.from(widget.quizData['choices']);
    String question = widget.quizData['question'];
    String summary = widget.quizData['summary'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Summary:', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              Text(summary, style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 16),
              Text('Question:', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              Text(question, style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 20),
              Text('Choose your answer:', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 8),
              ...choices.asMap().entries.map((entry) {
                int idx = entry.key;
                String choice = entry.value;
                return ListTile(
                  title: Text(choice),
                  leading: Radio<int>(
                    value: idx,
                    groupValue: _selectedChoiceIndex,
                    onChanged: (int? value) {
                      setState(() {
                        _selectedChoiceIndex = value;
                      });
                    },
                  ),
                );
              }).toList(),
              ElevatedButton(
                onPressed: _submitAnswer,
                child: const Text('Submit Answer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

