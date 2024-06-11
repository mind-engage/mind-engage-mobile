import 'package:flutter/material.dart';

class BaseUrlProvider extends InheritedWidget {
  final String baseUrl;

  const BaseUrlProvider({
    super.key,
    required super.child,
    required this.baseUrl,
  });

  static BaseUrlProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BaseUrlProvider>();
  }

  @override
  bool updateShouldNotify(BaseUrlProvider oldWidget) {
    return baseUrl != oldWidget.baseUrl;
  }
}