import 'package:get/get.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class FriendsController extends GetxController {
  final FirestoreService _db = Get.find<FirestoreService>();
  final AuthService _auth = Get.find<AuthService>();

  final RxList<AppUser> friends = <AppUser>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.firebaseUser.listen((user) {
      if (user != null) {
        friends.bindStream(_db.streamFriends(user.uid));
      } else {
        friends.clear();
      }
    });
  }

  Future<void> addFriend(String friendId) async {
    if (friendId.trim().isEmpty) return;
    if (friendId == _auth.appUser.value?.id) {
      Get.snackbar("Error", "You cannot add yourself as a friend.");
      return;
    }
    
    if (friends.any((f) => f.id == friendId)) {
      Get.snackbar("Notice", "This user is already your friend.");
      return;
    }

    isLoading.value = true;
    try {
      final friend = await _db.getUser(friendId);
      if (friend != null) {
        await _db.addFriend(_auth.appUser.value!.id, friend);
        Get.snackbar("Success", "Added ${friend.username} to your friend list.");
      } else {
        Get.snackbar("Error", "User not found.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to add friend: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _db.removeFriend(_auth.appUser.value!.id, friendId);
      Get.snackbar("Success", "Friend removed.");
    } catch (e) {
      Get.snackbar("Error", "Failed to remove friend: $e");
    }
  }
}
