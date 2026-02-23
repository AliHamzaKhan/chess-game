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
        title: const Text("Community"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildAddFriendSection(context),
            _buildRequestsList(context),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Friends", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildFriendList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context) {
    return Obx(() {
      if (controller.incomingRequests.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Pending Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: controller.incomingRequests.length,
            itemBuilder: (context, index) {
              final request = controller.incomingRequests[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.2),
                        child: Text(request.fromName[0].toUpperCase()),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(request.fromName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                            onPressed: () => controller.acceptRequest(request),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                            onPressed: () => controller.rejectRequest(request.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
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
                  hintText: "Search by User ID...",
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
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    controller.sendRequest(textController.text);
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
        return const Center(child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text("No friends yet. Add some to play!"),
        ));
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
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
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
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
                            Text(friend.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Text("Lvl ${friend.level}", style: TextStyle(fontSize: 11, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Text("${friend.points} pts", style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor)),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4, height: 4, 
                                  decoration: BoxDecoration(color: isOnline ? Colors.green : Colors.grey, shape: BoxShape.circle)
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isOnline ? "Online" : "Offline",
                                  style: TextStyle(fontSize: 10, color: isOnline ? Colors.green : Theme.of(context).hintColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.bolt, color: Colors.amber),
                            tooltip: "Quick Challenge",
                            onPressed: () => matchmakingService.sendChallenge(friend.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () => _showFriendOptions(context, friend),
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

  void _showFriendOptions(BuildContext context, AppUser friend) {
    Get.bottomSheet(
      GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("View Profile"),
              onTap: () {
                Get.back();
                // Profile view logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove, color: Colors.redAccent),
              title: const Text("Remove Friend", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                Get.back();
                _showRemoveDialog(context, friend.id, friend.username);
              },
            ),
          ],
        ),
      ),
    );
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
