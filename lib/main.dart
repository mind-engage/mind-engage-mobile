import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'home_page.dart';
import 'url_provider.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MindEngageApp());
}

class MindEngageApp extends StatelessWidget {
  const MindEngageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseUrlProvider(
      baseUrl: dotenv.get('MIND_ENGAGE_API', fallback: 'http://localhost:8080'),
      child: MaterialApp(
        title: 'MindEngage',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}









