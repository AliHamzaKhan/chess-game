import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../models/game_model.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/glass_container.dart';
import 'package:intl/intl.dart';

class MatchHistoryView extends StatelessWidget {
  final ProfileController controller = Get.find<ProfileController>();

  MatchHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        title: const Text('Match History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.recentMatches.isEmpty) {
          return const Center(child: Text("No matches played yet."));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.recentMatches.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final game = controller.recentMatches[index];
            return _buildMatchCard(context, game);
          },
        );
      }),
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

    final date = DateTime.fromMillisecondsSinceEpoch(game.lastMoveAt);
    final formattedDate = DateFormat('MMM dd, HH:mm').format(date);

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.withOpacity(0.1),
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('vs $opponentName', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(formattedDate, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
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
}
