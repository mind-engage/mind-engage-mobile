import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'url_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TranscriptPage extends StatefulWidget {
  final String lectureId;

  const TranscriptPage({super.key, required this.lectureId});

  @override
  _TranscriptPageState createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage> {
  String? _transcription;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTranscription();
    });
  }

  Future<void> fetchTranscription() async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/lecture/transcription/${widget.lectureId}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _transcription = data['transcription'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: 'Error loading transcription. Please try again.',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      Fluttertoast.showToast(
        msg: 'Error loading transcription. Please try again.',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcript Viewer'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text('Failed to load transcription'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          _transcription ?? 'No transcription available',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
