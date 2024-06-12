import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'topics_page.dart';
import 'url_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sessionId = "";
  List<dynamic> lectures = [];
  List<dynamic> topics = [];
  bool _showDisclaimer = true;

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

  Future<void> fetchLectures() async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/lectures?session_id=$_sessionId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        lectures = jsonDecode(response.body);
        _showDisclaimer = false;
      });
    } else {
      // Handle error, maybe show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading lectures. Please try again.'),
      ));
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child:  Text('MindEngage')),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.white],
          ),
        ),
        child: Center(
          child: _showDisclaimer ? _buildWelcomeScreen() : _buildLecturesList(),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_outline, size: 80, color: Colors.deepPurpleAccent),
          const SizedBox(height: 20),
          const Text(
            'MindEngage',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
          ),
          const SizedBox(height: 20),
          const Text(
            'Unlock a world of interactive learning. \nDiscover dynamic quizzes and embark on a\n personalized educational journey.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: fetchLectures,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text('Agree & Proceed', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Disclaimer: MindEngage is a Proof of Concept\n and may not always provide accurate information.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildLecturesList() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Available Lectures',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: lectures.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(lectures[index]['lecture_title']),
                subtitle: Text("License: ${lectures[index]['license']}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => fetchTopics(lectures[index]['lecture_id'].toString()),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}