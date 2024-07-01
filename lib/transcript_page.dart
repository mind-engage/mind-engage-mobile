import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'url_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:async';
import 'custom_app_bar.dart';

class TranscriptPage extends StatefulWidget {
  final String lectureId;
  final String lectureTitle;
  const TranscriptPage({super.key, required this.lectureId, required this.lectureTitle});

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
  bool isSpeaking = false;
  int _lastSpokenPosition = 0;
  StreamSubscription<dynamic>? _ttsProgressSubscription;
  List<String> _chunks = []; // Store the text chunks
  int _currentChunkIndex = 0; // Track the currently playing chunk

  @override
  void initState() {
    super.initState();
    _initTtsProgressListener();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchTranscription();
    });
    initTts();
  }

  @override
  void dispose() {
    isSpeaking = false;
    flutterTts.stop();
    _ttsProgressSubscription?.cancel();
    super.dispose();
  }

  void _initTtsProgressListener() {
    /*
    _ttsProgressSubscription = flutterTts.getProgressStream().listen((event) {
      if (event is int && event >= 0) {
        setState(() {
          _lastSpokenPosition = event;
        });
      }
    });
    */
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
        print("Chunk Complete");
        // Move to the next chunk if available
        if (_currentChunkIndex < _chunks.length - 1) {
          _currentChunkIndex++;
          _speakChunk(_chunks[_currentChunkIndex]); // Speak the next chunk
        } else {
          print("Complete");
          ttsState = TtsState.stopped;
          _currentChunkIndex = 0; // Reset to the beginning
        }
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

  Future<void> fetchTranscription() async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/lecture/transcription/${widget.lectureId}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          _transcription = data['transcription'];
          _chunks = _splitIntoChunks(_transcription!, 1000);
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
    if (_chunks.isNotEmpty) {
      if (isSpeaking) {
        await flutterTts.stop();
        isSpeaking = false;
      } else {
        await _speakChunk(_chunks[_currentChunkIndex]);
      }
    }
  }

  // Function to speak a single chunk
  Future<void> _speakChunk(String chunk) async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);

      if (selectedVoice != null) {
        await flutterTts.setVoice(selectedVoice!);
      }

      isSpeaking = true;
      await flutterTts.speak(chunk);
    } catch (e) {
      print("An error occurred during TTS: $e");
    }
  }

  Future<void> _stop() async {
    _currentChunkIndex = 0; // Reset chunk index
    var result = await flutterTts.stop();
    if (result == 1) setState(() => ttsState = TtsState.stopped);
    isSpeaking = false;
  }


  Future<void> _skipPrevious() async {
    if (_currentChunkIndex > 0) {
      _currentChunkIndex--; // Decrement the index first
      await flutterTts.stop(); // Stop the current playback
      await _speakChunk(_chunks[_currentChunkIndex]); // Speak the previous chunk
    }
  }

  Future<void> _skipNext() async {
    if (_currentChunkIndex < _chunks.length - 1) {
      _currentChunkIndex++; // Increment the index first
      await flutterTts.stop(); // Stop current playback
      await _speakChunk(_chunks[_currentChunkIndex]); // Speak the next chunk
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Transcript Viewer',
        subTitle: widget.lectureTitle,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(child: Text('Failed to load transcription'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Text(
              _transcription ?? 'No transcription available',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(isSpeaking ? Icons.stop : Icons.volume_up),
              onPressed: isSpeaking ? _stop : _speak,
              iconSize: 35,
            ),
            IconButton(
              icon: Icon(Icons.skip_previous),
              onPressed: _skipPrevious,
              iconSize: 35,
            ),

            IconButton(
              icon: Icon(Icons.skip_next),
              onPressed: _skipNext,
              iconSize: 35,
            ),
            Expanded(
              child: voices.isNotEmpty
                  ? DropdownButton<Map<String, String>>(
                isExpanded: true,
                hint: Center(child: Text("Select Voice")),
                value: selectedVoice,
                onChanged: (Map<String, String>? newValue) {
                  setState(() {
                    selectedVoice = newValue;
                  });
                },
                items: voices
                    .map<DropdownMenuItem<Map<String, String>>>((voice) {
                  return DropdownMenuItem<Map<String, String>>(
                    value: voice,
                    child: Center(child: Text(voice['name'] ?? '')),
                  );
                }).toList(),
              )
                  : Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}