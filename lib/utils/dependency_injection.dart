import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/matchmaking_service.dart';
import '../controllers/theme_controller.dart';
import '../controllers/game_controller.dart';
import '../controllers/friends_controller.dart';

class DependencyInjection {
  static void init() {
    Get.put(ThemeController(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(MatchmakingService());
    Get.put(GameController());
    Get.put(FriendsController());
  }
}
