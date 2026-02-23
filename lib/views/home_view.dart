import 'package:flutter/material.dart';
import 'package:flutter_chess_app/views/puzzle_view.dart';
import 'package:flutter_chess_app/views/setup_game_view.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/auth_service.dart';
import '../services/matchmaking_service.dart';
import '../controllers/friends_controller.dart';
import '../models/friend_request.dart';
import '../widgets/glass_container.dart';
import 'friends_view.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final AuthService auth = Get.find<AuthService>();
  final ThemeController themeController = Get.find<ThemeController>();
  final GameController gameController = Get.find<GameController>();
  final FriendsController friendsController = Get.put(FriendsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildAppBarContent(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.toNamed('/settings');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsRow(context),
            const SizedBox(height: 16),
            _buildFriendRequestsSection(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, "Start Playing", Icons.sports_esports),
            const SizedBox(height: 16),
            _buildOnlineMatchCard(context),
            const SizedBox(height: 16),
            _buildPlayVsComputerCard(context),
            const SizedBox(height: 32),
            _buildSectionHeader(context, "Daily Puzzle", Icons.extension),
            const SizedBox(height: 16),
            _buildDailyPuzzleCard(context),
            const SizedBox(height: 100), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildFriendRequestsSection(BuildContext context) {
    return Obx(() {
      if (friendsController.incomingRequests.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, "Community Activity", Icons.people_outline),
          const SizedBox(height: 12),
          ...friendsController.incomingRequests.map((request) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.person_add, color: Colors.blueAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                        children: [
                          TextSpan(text: request.fromName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: " wants to be friends"),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => friendsController.acceptRequest(request),
                    child: const Text("Accept", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => friendsController.rejectRequest(request.id),
                  ),
                ],
              ),
            ),
          )).toList(),
        ],
      );
    });
  }

  Widget _buildAppBarContent(BuildContext context) {
    return Obx(() {
      final user = auth.appUser.value;
      return Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: const AssetImage('assets/avatars/avatar1.png'), // Placeholder
            backgroundColor: Colors.grey.shade300,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(user?.username ?? 'GrandmasterFlash', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                    child: Text(
                      "${user?.elo ?? 1450}",
                      style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "^+5", // Mockup change
                    style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, "RAPID", "1204")),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, "BLITZ", "980")),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, "BULLET", "850")),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor, letterSpacing: 1.2, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOnlineMatchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Theme.of(context).cardTheme.color!.withOpacity(0.9), Theme.of(context).cardTheme.color!], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.public, size: 18, color: Colors.blue),
                    SizedBox(width: 8),
                    Text("Online Match", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Ranked • 10 min Rapid", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Matchmaking logic
                    Get.find<MatchmakingService>().findMatch();
                  },

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.bolt, size: 18), SizedBox(width: 8), Text("Quick Find")]),
                  ),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/chess_board_thumb.png', // Needs asset
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey.withOpacity(0.3), width: 100, height: 100, child: const Icon(Icons.grid_on)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayVsComputerCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => const SetupGameView());
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Theme.of(context).cardTheme.color, borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: [
            const Icon(Icons.smart_toy, size: 28, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Play vs Computer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text("Practice against Stockfish 16", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, shape: BoxShape.circle),
              child: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPuzzleCard(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/daily_puzzle.png'), // Needs asset
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.8)]),
            ),
          ),
          const Positioned(
            bottom: 20,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mate in 3",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 4),
                Text("White to move", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              onPressed: () {
                Get.to(() => const PuzzleView());
              },
              child: const Text("Solve"),
            ),
          ),
        ],
      ),
    );
  }
}
