import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'splash_screen.dart';
import 'home_page.dart';
import 'url_provider.dart';

void main() {
  runApp(const MindEngageApp());
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









