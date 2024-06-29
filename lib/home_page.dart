import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'topics_page.dart';
import 'url_provider.dart';
import 'courses_page.dart'; // Import CoursesPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sessionId = "";
  String _selectedCourseId = "00000000-0000-0000-0000-000000000000"; // Start with default course_id
  List<dynamic> lectures = [];
  List<dynamic> topics = [];
  bool _showWelcomeScreen = true; // Track which screen to show

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

  Future<void> fetchLectures(String courseId) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/lectures?session_id=$_sessionId&course_id=$courseId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        lectures = jsonDecode(response.body);
        _showWelcomeScreen = false; // Switch to lecture list screen
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading lectures. Please try again.'),
      ));
    }
  }

  void fetchTopics(String lectureId, String lectureTitle) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/topics?lecture_id=$lectureId&session_id=$_sessionId');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    setState(() {
      topics = data;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicsPage(sessionId: _sessionId, topics: topics, lectureTitle: lectureTitle, lectureId: lectureId,),
      ),
    );
  }

  Future<void> selectCourseAndFetchLectures() async {
    final selectedCourseId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CoursesPage()),
    );
    if (selectedCourseId != null) {
      setState(() {
        _selectedCourseId = selectedCourseId;
      });
      fetchLectures(selectedCourseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('MindEngage', style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.white),
            onPressed: selectCourseAndFetchLectures, // Add this action to change course_id
          ),
        ],
      ),
      body: _showWelcomeScreen ? _buildWelcomeScreen() : _buildLecturesList(),
    );
  }

  Widget _buildWelcomeScreen() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Colors.white],
        ),
      ),
      child: Center(
        child: Padding(
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
                onPressed: () => fetchLectures(_selectedCourseId),
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
        ),
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
              return InkWell(
                onTap: () => fetchTopics(lectures[index]['lecture_id'].toString(), lectures[index]['lecture_title']),
                child: ListTile(
                  title: Text(lectures[index]['lecture_title']),
                  subtitle: Text("License: ${lectures[index]['license']}"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
