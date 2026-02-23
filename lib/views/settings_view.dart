import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../controllers/friend_controller.dart';
import '../services/auth_service.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final FriendController friendController = Get.put(FriendController());
    final AuthService auth = Get.find<AuthService>();
    final TextEditingController friendIdInput = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Dark mode toggle
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Obx(() => Switch(
              value: themeController.isDarkMode,
              onChanged: (_) => themeController.toggleTheme(),
            )),
          ),
          const Divider(),
          // Share your ID
          Obx(() => ListTile(
            title: const Text('Your ID'),
            subtitle: Text(friendController.userId.value),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: friendController.copyUserId,
            ),
          )),
          const Divider(),
          // Play with friend
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Enter Friend ID to Play'),
                const SizedBox(height: 8),
                TextField(
                  controller: friendIdInput,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Friend ID',
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final id = friendIdInput.text.trim();
                    if (id.isNotEmpty) {
                      friendController.setOpponent(id);
                      friendController.startGameWithFriend();
                    } else {
                      Get.snackbar('Error', 'Please enter a friend ID');
                    }
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play with Friend'),
                ),
              ],
            ),
          ),
          const Divider(),
          // Logout option
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await auth.signOut();
              Get.offAllNamed('/login');
            },
          ),
          const Divider(),
          // Add more settings here as needed
        ],
      ),
    );
  }
}
