import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/learn_controller.dart';
import '../models/lesson.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/glass_container.dart';
import 'lesson_detail_view.dart';

class CategoryLessonsView extends StatelessWidget {
  final String category;
  final LearnController controller = Get.find<LearnController>();

  CategoryLessonsView({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final filteredLessons = controller.lessons.where((l) => l.category == category).toList();

    return BackgroundScaffold(
      appBar: AppBar(
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredLessons.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final lesson = filteredLessons[index];
          return _buildLessonItem(context, lesson);
        },
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context, Lesson lesson) {
    return GestureDetector(
      onTap: () => Get.to(() => LessonDetailView(lesson: lesson)),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: lesson.color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(lesson.icon, color: lesson.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(lesson.subtitle, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
