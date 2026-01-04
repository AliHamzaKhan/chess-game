import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firestore_service.dart';
import '../models/app_user.dart';

class LeaderboardView extends StatelessWidget {
  final FirestoreService db = Get.find<FirestoreService>();

  LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Global Ranking")),
      body: StreamBuilder<List<AppUser>>(
        stream: db.getLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data"));
          }

          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                   backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                   child: user.photoUrl.isEmpty ? Text("${index + 1}") : null,
                ),
                title: Text(user.username),
                subtitle: Text("Level ${user.level}"),
                trailing: Text("${user.points} pts", style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          );
        },
      ),
    );
  }
}
