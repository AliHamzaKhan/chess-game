import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/friends_controller.dart';
import '../services/matchmaking_service.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/glass_container.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';

class FriendsView extends StatelessWidget {
  final FriendsController controller = Get.find<FriendsController>();
  final MatchmakingService matchmakingService = Get.find<MatchmakingService>();

  FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text("My Friends"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildAddFriendSection(context),
          const SizedBox(height: 20),
          Expanded(child: _buildFriendList(context)),
        ],
      ),
    );
  }

  Widget _buildAddFriendSection(BuildContext context) {
    final textController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: "Enter User ID to add",
                  border: InputBorder.none,
                ),
              ),
            ),
            Obx(() => controller.isLoading.value
              ? const SizedBox(
                  width: 24, height: 24, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                )
              : IconButton(
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  onPressed: () {
                    controller.addFriend(textController.text);
                    textController.clear();
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendList(BuildContext context) {
    return Obx(() {
      if (controller.friends.isEmpty) {
        return const Center(child: Text("You haven't added any friends yet."));
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.friends.length,
        itemBuilder: (context, index) {
          final friendSummary = controller.friends[index];
          return StreamBuilder<AppUser?>(
            stream: Get.find<FirestoreService>().streamUser(friendSummary.id),
            builder: (context, snapshot) {
              final friend = snapshot.data ?? friendSummary;
              final bool isOnline = friend.isOnline;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            child: Text(friend.username.isNotEmpty ? friend.username[0].toUpperCase() : "?"),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(friend.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Row(
                              children: [
                                Text("Points: ${friend.points}", style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                                const SizedBox(width: 8),
                                Text(
                                  isOnline ? "Online" : "Offline",
                                  style: TextStyle(
                                    fontSize: 10, 
                                    color: isOnline ? Colors.green : Theme.of(context).hintColor,
                                    fontWeight: isOnline ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_outline, color: Colors.green),
                            tooltip: "Challenge",
                            onPressed: () => matchmakingService.sendChallenge(friend.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.person_remove_outlined, color: Colors.redAccent),
                            tooltip: "Remove",
                            onPressed: () => _showRemoveDialog(context, friend.id, friend.username),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
          );
        },
      );
    });
  }

  void _showRemoveDialog(BuildContext context, String friendId, String username) {
    Get.defaultDialog(
      title: "Remove Friend",
      middleText: "Are you sure you want to remove $username?",
      textCancel: "Cancel",
      textConfirm: "Remove",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.removeFriend(friendId);
        Get.back();
      },
    );
  }
}
