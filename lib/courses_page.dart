import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'custom_app_bar.dart';

import 'url_provider.dart';

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
        title: 'MindEngage',
        //subTitle: 'Course Dashboard',
      ),
      body: ListView.builder(
        itemCount: courses.length,
        itemBuilder: (context, index) {
          return ListTile(
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
              Map<String, dynamic> selectedCourse = {
                'course_id': courses[index]['course_id'],
                'course_name': courses[index]['course_name'],
              };
              // Return the map
              Navigator.pop(context, selectedCourse);
            },
          );
        },
      ),
    );
  }
}
