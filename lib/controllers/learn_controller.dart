import 'package:get/get.dart';
import '../models/lesson.dart';
import '../services/learn_service.dart';

class LearnController extends GetxController {
  // List of lessons
  final RxList<Lesson> lessons = <Lesson>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLessons();
  }

  void loadLessons() {
    // In a real app this could be async fetching from Firestore or API
    lessons.assignAll(LearnService.getLessons());
  }

  Lesson? getLessonById(String id) {
    return lessons.firstWhereOrNull((l) => l.id == id);
  }
}
