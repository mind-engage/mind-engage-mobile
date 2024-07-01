import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'topics_page.dart';
import 'url_provider.dart';
import 'courses_page.dart';
import 'transcript_page.dart';
import 'custom_app_bar.dart';

class LecturesPage extends StatefulWidget {
  final String sessionId;

  const LecturesPage({Key? key, required this.sessionId}) : super(key: key);

  @override
  _LecturesPageState createState() => _LecturesPageState();
}

class _LecturesPageState extends State<LecturesPage> {
  String _selectedCourseId = "00000000-0000-0000-0000-000000000000";
  String _courseName = "Demo Course";

  List<dynamic> lectures = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLectures(_selectedCourseId);
    });
  }

  Future<void> _fetchLectures(String courseId) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/lectures?session_id=${widget.sessionId}&course_id=$courseId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        lectures = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error loading lectures. Please try again.'),
      ));
    }
  }

  void _fetchTopics(String lectureId, String lectureTitle) async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/topics?lecture_id=$lectureId&session_id=${widget.sessionId}');
    var response = await http.get(url);
    var data = jsonDecode(response.body);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TopicsPage(sessionId: widget.sessionId, topics: data, lectureTitle: lectureTitle, lectureId: lectureId,),
      ),
    );
  }

  Future<void> _selectCourseAndFetchLectures() async {
    final selectedCourse = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CoursesPage()),
    );
    if (selectedCourse != null && selectedCourse is Map) {
      setState(() {
        _selectedCourseId = selectedCourse['course_id'];
        _courseName = selectedCourse['course_name'];
      });
      _fetchLectures(_selectedCourseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'MindEngage',
        subTitle: _courseName,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.white),
            onPressed: _selectCourseAndFetchLectures,
          ),
        ],
      ),
      body: _buildLecturesList(),
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
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.description, size: 20),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => TranscriptPage(lectureId: lectures[index]['lecture_id'], lectureTitle: lectures[index]['lecture_title'] ),
                          ),
                        );
                      },
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onTap: () => _fetchTopics(lectures[index]['lecture_id'].toString(), lectures[index]['lecture_title']),
              );
            },
          ),
        ),
      ],
    );
  }
}