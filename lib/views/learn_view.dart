import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/glass_container.dart';
import '../controllers/learn_controller.dart';
import '../models/lesson.dart';
import 'lesson_detail_view.dart';
import 'category_lessons_view.dart';

class LearnView extends StatefulWidget {
  const LearnView({super.key});

  @override
  State<LearnView> createState() => _LearnViewState();
}

class _LearnViewState extends State<LearnView> {
  late final LearnController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LearnController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn Chess", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Obx(() {
        if (controller.lessons.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final fundamentals = controller.lessons.where((l) => l.category == 'Fundamentals' || l.category == 'Advanced').take(3).toList();
        final strategy = controller.lessons.where((l) => l.category == 'Strategy').take(3).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildFeaturedCourse(context),
            const SizedBox(height: 24),
            _buildSectionHeader("Fundamentals", () => Get.to(() => CategoryLessonsView(category: 'Fundamentals'))),
            const SizedBox(height: 16),
            ...fundamentals.map((lesson) => _buildLessonItem(context, lesson)).toList(),
            const SizedBox(height: 24),
            _buildSectionHeader("Strategy", () => Get.to(() => CategoryLessonsView(category: 'Strategy'))),
            const SizedBox(height: 16),
            ...strategy.map((lesson) => _buildLessonItem(context, lesson)).toList(),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: onTap,
          child: const Text("View All"),
        ),
      ],
    );
  }

  Widget _buildLessonItem(BuildContext context, Lesson lesson) {
    return GestureDetector(
      onTap: () => Get.to(() => LessonDetailView(lesson: lesson)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lesson.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
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
      ),
    );
  }

  Widget _buildFeaturedCourse(BuildContext context) {
    // ... (rest of the code remains same, but I'll update the button to navigate to a lesson for demonstration)
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/learn_banner.png'), 
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text("COURSE", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                const Text("Mastering the Endgame", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text("Learn how to convert advantages into wins.", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (controller.lessons.isNotEmpty) {
                       Get.to(() => LessonDetailView(lesson: controller.lessons.first));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Start Learning"),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
