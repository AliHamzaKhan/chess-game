import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/game_model.dart';
import '../services/auth_service.dart';
import '../controllers/theme_controller.dart';
import '../controllers/profile_controller.dart';
import '../models/app_user.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final AuthService auth = Get.find<AuthService>();
  final ThemeController themeController = Get.find<ThemeController>();
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Get.toNamed('/settings')),
        ],
      ),
      body: Obx(() {
        final AppUser? user = controller.user.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context, user),
              const SizedBox(height: 24),
              _buildStatsRow(context),
              const SizedBox(height: 24),
              _buildPerformanceSection(context),
              const SizedBox(height: 24),
              _buildMatchHistorySection(context),
              const SizedBox(height: 24),
              _buildAchievementsSection(context),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AppUser user) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.purple, width: 3),
                  gradient: const LinearGradient(colors: [Colors.purple, Colors.blue]),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : const AssetImage('assets/avatars/avatar1.png') as ImageProvider,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: const Text('PRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
              child: const Text('🇺🇸 US', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Global Rank #${user.rank}', style: TextStyle(color: Theme.of(context).hintColor)),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(context, 'Rating', '${controller.points}', Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Win Rate', '${controller.winRate.toStringAsFixed(0)}%', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(context, 'Matches', '${controller.matches}', Colors.purple)),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Obx(() => Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _TabButton(
                    text: 'Blitz', 
                    selected: controller.selectedMode.value == 'Blitz',
                    onTap: () => controller.selectMode('Blitz'),
                  ),
                  _TabButton(
                    text: 'Rapid', 
                    selected: controller.selectedMode.value == 'Rapid',
                    onTap: () => controller.selectMode('Rapid'),
                  ),
                  _TabButton(
                    text: 'Classical', 
                    selected: controller.selectedMode.value == 'Classical',
                    onTap: () => controller.selectMode('Classical'),
                  ),
                ],
              ),
            )),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          final data = controller.getGraphData();
          return Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMatchHistorySection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Match History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => Get.toNamed('/match_history'), 
              child: const Text('View All')
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.recentMatches.isEmpty) {
            return const Center(child: Text("No matches played yet."));
          }
          // Show only first 3 in profile summary
          final displayMatches = controller.recentMatches.take(3).toList();
          return Column(
            children: displayMatches.map((game) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildMatchCard(context, game),
            )).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, GameModel game) {
    final String myId = controller.user.value?.id ?? '';
    final bool amIWhite = game.whitePlayerId == myId;
    final String opponentName = amIWhite ? game.blackPlayerName : game.whitePlayerName;
    
    String result = 'Draw';
    Color resultColor = Colors.grey;
    String points = '0';

    if (game.winnerId != null) {
      if (game.winnerId == myId) {
        result = 'Won';
        resultColor = Colors.green;
        points = '+10';
      } else {
        result = 'Lost';
        resultColor = Colors.red;
        points = '-10';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.withOpacity(0.1),
            child: const Icon(Icons.person, size: 20, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('vs $opponentName', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(game.status == 'finished' ? 'Played' : 'Active', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(points, style: TextStyle(fontWeight: FontWeight.bold, color: resultColor, fontSize: 16)),
              Text(result, style: TextStyle(fontSize: 12, color: resultColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('12/45 Earned', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _AchievementCard(title: 'Win Streak', subtitle: 'Won 5 games in a row', icon: Icons.emoji_events, color: Colors.amber),
              SizedBox(width: 16),
              _AchievementCard(title: 'Tactician', subtitle: 'Solved 100 puzzles', icon: Icons.psychology, color: Colors.purple),
              SizedBox(width: 16),
              _AchievementCard(title: 'Grandmaster', subtitle: 'Reach 2500 ELO', icon: Icons.lock, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }
}

// Helper widgets
class _TabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.text, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(text, style: TextStyle(fontSize: 12, color: selected ? Colors.white : Theme.of(context).hintColor)),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _AchievementCard({required this.title, required this.subtitle, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
          const SizedBox(height: 8),
          Container(height: 4, width: 40, color: color),
        ],
      ),
    );
  }
}
