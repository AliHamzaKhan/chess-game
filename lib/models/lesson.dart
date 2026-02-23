import 'package:flutter/material.dart';

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String content; // could be markdown or plain text
  final int iconCodePoint; // store IconData code point
  int? iconFontFamily; // not needed, using material icons
  final int colorValue; // store Color as int
  final String category; // e.g. 'Fundamentals', 'Strategy'

  Lesson({required this.id, required this.title, required this.subtitle, required this.description, required this.content, required this.iconCodePoint, required this.colorValue, required this.category});

  // Helper to get IconData
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  // Helper to get Color
  Color get color => Color(colorValue);
}
