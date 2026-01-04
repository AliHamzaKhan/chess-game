import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';

class ProfileView extends StatelessWidget {
  final AuthService auth = Get.find<AuthService>();

  ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Obx(() {
        final user = auth.appUser.value;
        if (user == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
             children: [
                CircleAvatar(
                   radius: 50,
                   backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                   child: user.photoUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        color: user.isOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(user.isOnline ? "Online" : "Offline", style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(user.username, style: Theme.of(context).textTheme.headlineMedium),
                Text(user.email.isNotEmpty ? user.email : "Guest Account", style: Theme.of(context).textTheme.bodySmall),
                
                const SizedBox(height: 10),
                Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                   decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                   child: SelectableText("ID: ${user.id}", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                
                const SizedBox(height: 30),
                
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                      _statItem("Points", user.points.toString()),
                      _statItem("Level", user.level.toString()),
                   ],
                ),
                const SizedBox(height: 20),
                Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                      _statItem("Matches", user.matchesPlayed.toString()),
                      _statItem("Wins", user.wins.toString()),
                      _statItem("Losses", user.losses.toString()),
                   ],
                ),
                
                // Add Edit Profile Button later
             ],
          ),
        );
      }),
    );
  }
  
  Widget _statItem(String label, String value) {
      return Column(
         children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
         ],
      );
  }
}
