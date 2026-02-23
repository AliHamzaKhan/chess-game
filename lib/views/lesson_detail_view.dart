import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/glass_container.dart';

class LessonDetailView extends StatelessWidget {
  final Lesson lesson;
  const LessonDetailView({required this.lesson, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lesson.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lesson.title,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(lesson.description,
                  style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
              const Divider(height: 32),
              // For now we just display raw markdown text.
              // Replace with a markdown renderer (e.g., flutter_markdown) later.
              Text(lesson.content, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
