import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'url_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class TranscriptPage extends StatefulWidget {
  final String lectureId;

  const TranscriptPage({super.key, required this.lectureId});

  @override
  _TranscriptPageState createState() => _TranscriptPageState();
}

enum TtsState { playing, stopped, paused, continued }

class _TranscriptPageState extends State<TranscriptPage> {
  String? _transcription;
  bool _isLoading = true;
  bool _hasError = false;
  FlutterTts flutterTts = FlutterTts();

  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;
  Map<String, String>? selectedVoice;

  TtsState ttsState = TtsState.stopped;

  bool get isPlaying => ttsState == TtsState.playing;
  bool get isStopped => ttsState == TtsState.stopped;
  bool get isPaused => ttsState == TtsState.paused;
  bool get isContinued => ttsState == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isWeb => kIsWeb;

  List<dynamic> voices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTranscription();
    });
    initTts();
  }

  dynamic initTts() {
    flutterTts = FlutterTts();

    _setAwaitOptions();

    if (isAndroid) {
      _getDefaultEngine();
      _getDefaultVoice();
    }

    flutterTts.setStartHandler(() {
      setState(() {
        print("Playing");
        ttsState = TtsState.playing;
      });
    });

    flutterTts.setCompletionHandler(() {
      setState(() {
        print("Complete");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setCancelHandler(() {
      setState(() {
        print("Cancel");
        ttsState = TtsState.stopped;
      });
    });

    flutterTts.setPauseHandler(() {
      setState(() {
        print("Paused");
        ttsState = TtsState.paused;
      });
    });

    flutterTts.setContinueHandler(() {
      setState(() {
        print("Continued");
        ttsState = TtsState.continued;
      });
    });

    flutterTts.setErrorHandler((msg) {
      setState(() {
        print("error: $msg");
        ttsState = TtsState.stopped;
      });
    });

    _getVoices();
  }

  Future<void> _getVoices() async {
    var voices = await flutterTts.getVoices;
    if (voices != null) {
      setState(() {
        this.voices = List<Map<String, String>>.from(
            voices.where((voice) => (voice['name'] as String).startsWith('en')).map((voice) => Map<String, String>.from(voice))
        );
      });
    }
  }


  Future<dynamic> _getLanguages() async => await flutterTts.getLanguages;

  Future<dynamic> _getEngines() async => await flutterTts.getEngines;

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }

  Future<void> _setAwaitOptions() async {
    await flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _stop() async {
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
  }

  Future<void> _pause() async {
    var result = await flutterTts.pause();
    if (result == 1) setState(() => ttsState = TtsState.paused);
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

  List<String> _splitIntoChunks(String text, int chunkSize) {
    List<String> chunks = [];
    int start = 0;
    while (start < text.length) {
      int end = start + chunkSize;
      if (end > text.length) {
        end = text.length;
      }
      chunks.add(text.substring(start, end));
      start = end;
    }
    return chunks;
  }

  Future<void> _speak() async {
    if (_transcription != null && _transcription!.isNotEmpty) {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      if (selectedVoice != null) {
        await flutterTts.setVoice(selectedVoice!);
      }

      List<String> chunks = _splitIntoChunks(_transcription!, 1000);

      for (String chunk in chunks) {
        await flutterTts.speak(chunk);
        await flutterTts.awaitSpeakCompletion(true);
      }
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcript Viewer'),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.volume_up),
            onPressed: _speak,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text('Failed to load transcription'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (voices.isNotEmpty)
              DropdownButton<Map<String, String>>(
                hint: Text("Select Voice"),
                value: selectedVoice,
                onChanged: (Map<String, String>? newValue) {
                  setState(() {
                    selectedVoice = newValue;
                  });
                },
                items: voices.map<DropdownMenuItem<Map<String, String>>>((voice) {
                  return DropdownMenuItem<Map<String, String>>(
                    value: voice,
                    child: Text(voice['name'] ?? ''),
                  );
                }).toList(),
              ),
            SizedBox(height: 20),
            Text(
              _transcription ?? 'No transcription available',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
