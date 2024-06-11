import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
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
  bool _showDisclaimer = true;  // State to control visibility of the disclaimer and button

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
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        lectures = data;
        _showDisclaimer = false;  // Hide disclaimer and button after fetching lectures
      });
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
        title: const Text('MindEngage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_showDisclaimer)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Disclaimer: MindEngage utilizes advanced generative AI technologies. "
                      "Please note that this application is a Proof of Concept (PoC) and intended "
                      "for demonstration purposes only. The content and interactions may not always "
                      "reflect accurate or verified information.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                  ),
                ),
              ),
            if (_showDisclaimer)
              ElevatedButton(
                onPressed: fetchLectures,
                child: const Text('Agree and Proceed'),
              ),
            if (!_showDisclaimer)  // Only show if disclaimer has been agreed to
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Available Lectures',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            if (!_showDisclaimer)  // List lectures if disclaimer is not shown
              Expanded(
                child: ListView.separated(
                  itemCount: lectures.length,
                  separatorBuilder: (context, index) => Divider(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1.0, horizontal: 8.0),
                      child:ListTile(
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text(lectures[index]['lecture_title']),
                        ),
                        subtitle:Text("License: ${lectures[index]['license']}"),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => fetchTopics(lectures[index]['lecture_id'].toString()),
                        tileColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        hoverColor: Colors.blue.shade100,
                      ),
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