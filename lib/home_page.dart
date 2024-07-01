import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'lectures_page.dart'; // Import the renamed LecturesPage
import 'url_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _sessionId = "";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('MindEngage', style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: _buildWelcomeScreen(),
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
                onPressed: () {
                  // Navigate directly to LecturesPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LecturesPage(sessionId: _sessionId),
                    ),
                  );
                },
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
}