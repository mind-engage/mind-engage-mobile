import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final String? lectureName; // Add lectureName parameter
  final String? topicName;    // Add topicName parameter

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.lectureName,
    this.topicName
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to the start
        children: [
          Text(title),
          if (lectureName != null)
            Text(lectureName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
          if (topicName != null)
            Text(topicName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300)),
        ],
      ),
      backgroundColor: Colors.deepPurpleAccent,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.5);
}