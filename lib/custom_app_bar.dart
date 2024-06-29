import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final String? subTitle; // Add lectureName parameter
  final String? description;    // Add topicName parameter

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.subTitle,
    this.description
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to the start
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          if (subTitle != null)
            Text(subTitle!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white)),
          if (description != null)
            Text(description!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Colors.white)),
        ],
      ),
      backgroundColor: Colors.deepPurpleAccent,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 1.5);
}