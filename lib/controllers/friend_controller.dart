import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/matchmaking_service.dart';

class FriendController extends GetxController {
  final AuthService _auth = Get.find<AuthService>();
  final MatchmakingService _matchmaking = Get.find<MatchmakingService>();

  // Use actual Firebase UID
  final RxString userId = RxString('');
  final RxString _opponentId = RxString('');
  
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth changes to update current user ID
    _authSubscription = _auth.firebaseUser.listen((user) {
      if (user != null) {
        userId.value = user.uid;
      } else {
        userId.value = '';
      }
    });
    
    // Initial set if user is already logged in
    if (_auth.firebaseUser.value != null) {
      userId.value = _auth.firebaseUser.value!.uid;
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  // Copy own ID to clipboard
  void copyUserId() {
    if (userId.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: userId.value));
      Get.snackbar('Copied', 'Your ID has been copied to clipboard');
    } else {
      Get.snackbar('Error', 'User ID not found. Are you logged in?');
    }
  }

  // Set opponent ID enters by user
  void setOpponent(String id) {
    _opponentId.value = id;
  }

  // Start a game with the opponent using the MatchmakingService challenge system
  void startGameWithFriend() {
    if (userId.value.isEmpty) {
      Get.snackbar('Error', 'You must be logged in to play.');
      return;
    }
    
    if (_opponentId.value.isEmpty) {
      Get.snackbar('Error', 'Opponent ID is empty');
      return;
    }

    if (_opponentId.value == userId.value) {
      Get.snackbar('Error', 'You cannot play against yourself.');
      return;
    }
    
    // Trigger the real-time challenge flow
    _matchmaking.sendChallenge(_opponentId.value);
  }

  // Expose opponent ID for UI if needed
  String get opponentId => _opponentId.value;
}
