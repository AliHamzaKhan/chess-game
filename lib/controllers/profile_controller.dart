import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';
import '../models/game_model.dart';

class ProfileController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final FirestoreService _firestore = Get.find<FirestoreService>();

  // Reactive user data
  final Rx<AppUser?> user = Rx<AppUser?>(null);
  // Stats
  final RxInt points = 0.obs;
  final RxInt wins = 0.obs;
  final RxInt losses = 0.obs;
  final RxInt matches = 0.obs;
  final RxList<int> ratingHistory = <int>[].obs;
  
  // Recent Matches
  final RxList<GameModel> recentMatches = <GameModel>[].obs;
  
  // Performance Tab selection
  final RxString selectedMode = 'Rapid'.obs;
  
  void selectMode(String mode) {
    selectedMode.value = mode;
  }

  List<int> getGraphData() {
    if (ratingHistory.isEmpty) return [1000, 1000];
    
    // For now, Blitz and Classical are derived from Rapid for visual demo
    if (selectedMode.value == 'Blitz') {
      return ratingHistory.map((e) => (e * 0.9).round()).toList();
    } else if (selectedMode.value == 'Classical') {
      return ratingHistory.map((e) => (e * 1.1).round()).toList();
    }
    return ratingHistory;
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to auth changes
    ever(_auth.appUser, (_) => _loadUserData());
    // Initial load if already logged in
    if (_auth.appUser.value != null) {
      _loadUserData();
    }
  }

  void _loadUserData() async {
    final uid = _auth.appUser.value?.id;
    if (uid == null) return;
    
    // Stream user document for live updates
    _firestore.streamUser(uid).listen((appUser) {
      if (appUser != null) {
        user.value = appUser;
        points.value = appUser.points;
        wins.value = appUser.wins;
        losses.value = appUser.losses;
        matches.value = appUser.matchesPlayed;
        // Assume ratingHistory stored as List<dynamic>
        if (appUser.ratingHistory != null && appUser.ratingHistory.isNotEmpty) {
          ratingHistory.assignAll(List<int>.from(appUser.ratingHistory!));
        } else {
          ratingHistory.assignAll([1000, 1000]); // Default starting trend
        }
      }
    });

    // Stream match history
    _firestore.streamMyMatchHistory(uid).listen((games) {
        recentMatches.assignAll(games);
    });
  }

  double get winRate => matches.value == 0 ? 0 : (wins.value / matches.value) * 100;
}
