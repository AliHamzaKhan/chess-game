import 'package:get/get.dart';
import '../models/app_user.dart';
import '../models/friend_request.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class FriendsController extends GetxController {
  final FirestoreService _db = Get.find<FirestoreService>();
  final AuthService _auth = Get.find<AuthService>();

  final RxList<AppUser> friends = <AppUser>[].obs;
  final RxList<FriendRequest> incomingRequests = <FriendRequest>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _auth.firebaseUser.listen((user) {
      if (user != null) {
        friends.bindStream(_db.streamFriends(user.uid));
        incomingRequests.bindStream(_db.streamIncomingFriendRequests(user.uid));
      } else {
        friends.clear();
        incomingRequests.clear();
      }
    });
  }

  Future<void> sendRequest(String friendId) async {
    if (friendId.trim().isEmpty) return;
    final myId = _auth.appUser.value?.id;
    final myName = _auth.appUser.value?.username ?? 'User';

    if (myId == null) return;
    if (friendId == myId) {
      Get.snackbar("Error", "You cannot add yourself.");
      return;
    }
    
    if (friends.any((f) => f.id == friendId)) {
      Get.snackbar("Notice", "Already friends.");
      return;
    }

    isLoading.value = true;
    try {
      final targetUser = await _db.getUser(friendId);
      if (targetUser != null) {
        await _db.sendFriendRequest(myId, myName, friendId);
        Get.snackbar("Success", "Request sent to ${targetUser.username}");
      } else {
        Get.snackbar("Error", "User not found.");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptRequest(FriendRequest request) async {
    try {
      await _db.acceptFriendRequest(request);
      Get.snackbar("Success", "You are now friends!");
    } catch (e) {
      Get.snackbar("Error", "Failed to accept: $e");
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _db.rejectFriendRequest(requestId);
    } catch (e) {
      Get.snackbar("Error", "Failed: $e");
    }
  }

  Future<void> removeFriend(String friendId) async {
    try {
      await _db.removeFriend(_auth.appUser.value!.id, friendId);
    } catch (e) {
      Get.snackbar("Error", "Failed: $e");
    }
  }
}
