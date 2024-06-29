import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lecture_creation.dart'; // Import your lecture creation screen
import 'custom_app_bar.dart'; // Import the custom app bar
import 'user_profile.dart'; // Import UserProfileScreen
import 'course_edit.dart'; // Import LectureEditScreen
import 'course_creation.dart'; // Import LectureEditScreen

import 'lecture_dashboard.dart'; // Import LectureEditScreen

import 'url_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CoursesPage extends StatefulWidget {
  // final String creatorId = "Various Authors";
  const CoursesPage({Key? key}) : super(key: key);

  @override
  CoursesPageState createState() => CoursesPageState();
}

class CoursesPageState extends State<CoursesPage> {
  // Sample lecture data (Replace with your actual data fetching logic)
  List<dynamic> courses = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCourses();
    });
  }

  Future<void> fetchCourses() async {
    String baseUrl = BaseUrlProvider.of(context)!.baseUrl;
    var url = Uri.parse('$baseUrl/courses');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        courses = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // Use the custom app bar
        title: 'MindEngage Creator',
        //subTitle: 'Course Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // Navigate to User Profile screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileScreen(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {

            background: Container(
              color: Colors.red,
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            direction: DismissDirection.endToStart,
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(courses[index]['thumbnail'] ??
                        'assets/images/default_thumbnail.png'), // Provide a default image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(courses[index]['course_name']),
              subtitle: Text(
                courses[index]['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                // Navigate to Lecture Editing screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LectureDashboard(
                      user: widget.user,
                      courseId: courses[index]['course_id']
                    ),
                  ),
                );
              },
          );
        },
      ),
    );
  }
}