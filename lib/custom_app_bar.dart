import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions; // Add actions parameter

  const CustomAppBar({Key? key, required this.title, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title:  Text(title),
      backgroundColor: Colors.deepPurpleAccent,
      actions: actions, // Use the provided actions
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}