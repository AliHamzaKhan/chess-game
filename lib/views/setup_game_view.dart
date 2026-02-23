import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../widgets/glass_container.dart';

class SetupGameView extends StatefulWidget {
  const SetupGameView({super.key});

  @override
  State<SetupGameView> createState() => _SetupGameViewState();
}

class _SetupGameViewState extends State<SetupGameView> {
  final GameController gameController = Get.find<GameController>();
  
  BotDifficulty _selectedDifficulty = BotDifficulty.medium;
  int _selectedColor = 0; // 0: White, 1: Black, 2: Random
  int _selectedOpponent = 0;

  final List<Map<String, dynamic>> _opponents = [
    {'name': 'Alice', 'elo': 1200, 'style': 'Balanced Player', 'image': 'assets/avatars/alice.png', 'color': Colors.blue},
    {'name': 'Marcus', 'elo': 1450, 'style': 'Aggressive', 'image': 'assets/avatars/marcus.png', 'color': Colors.red},
    {'name': 'Stockfish', 'elo': 3000, 'style': 'Grandmaster', 'image': 'assets/avatars/stockfish.png', 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setup Game", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("OPPONENT", "View All"),
            const SizedBox(height: 16),
            _buildOpponentSelector(context),
            const SizedBox(height: 32),
            _buildSectionTitle("DIFFICULTY LEVEL", ""),
            const SizedBox(height: 16),
            _buildDifficultyOption(context, BotDifficulty.easy, "Low", "400 ELO", "Perfect for beginners learning the ropes.", Colors.green),
            const SizedBox(height: 12),
            _buildDifficultyOption(context, BotDifficulty.medium, "Medium", "1200 ELO", "A solid challenge for club players.", Colors.orange),
            const SizedBox(height: 12),
            _buildDifficultyOption(context, BotDifficulty.hard, "High", "2000+ ELO", "Unforgiving tactical precision.", Colors.red),
            const SizedBox(height: 32),
            _buildSectionTitle("PLAY AS", ""),
            const SizedBox(height: 16),
            _buildColorSelector(context),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                   String? color = 'w';
                   if (_selectedColor == 0) color = 'w';
                   else if (_selectedColor == 1) color = 'b';
                   else color = Random().nextBool() ? 'w' : 'b';

                   gameController.startGame(mode: GameMode.bot, difficulty: _selectedDifficulty, asColor: color);
                   Get.toNamed('/game');
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eighteen_mp, size: 24),
                    SizedBox(width: 8),
                    Text("Start Game", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).hintColor, letterSpacing: 1.2)),
        if (action.isNotEmpty)
          TextButton(
            onPressed: () {},
            child: Text(action),
          ),
      ],
    );
  }

  Widget _buildOpponentSelector(BuildContext context) {
    return SizedBox(
      height: 195,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _opponents.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final opponent = _opponents[index];
          final isSelected = _selectedOpponent == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedOpponent = index),
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
              ),
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.all(3),
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.transparent, width: 2),
                       boxShadow: isSelected ? [BoxShadow(color: Theme.of(context).primaryColor.withOpacity(0.4), blurRadius: 10)] : null,
                     ),
                     child: CircleAvatar(
                       radius: 40,
                       backgroundColor: (opponent['color'] as Color).withOpacity(0.2),
                       child: Icon(Icons.person, size: 40, color: opponent['color']),
                     ),
                   ),
                   const SizedBox(height: 12),
                   if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(10)),
                        child: Text("ELO ${opponent['elo']}", style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                   const SizedBox(height: 4),
                   Text(opponent['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                   Text(opponent['style'], style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDifficultyOption(BuildContext context, BotDifficulty difficulty, String title, String elo, String desc, Color color) {
    final isSelected = _selectedDifficulty == difficulty;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = difficulty),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(Icons.bolt, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Theme.of(context).dividerColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text(elo, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                ],
              ),
            ),
            if (isSelected)
               const Icon(Icons.radio_button_checked, color: Colors.blue)
            else
               Icon(Icons.radio_button_off, color: Theme.of(context).hintColor),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _colorOption(context, 0, "White", Colors.white, Colors.black),
        _colorOption(context, 1, "Black", Colors.black87, Colors.white),
        _colorOption(context, 2, "Random", Colors.grey, Colors.white),
      ],
    );
  }

  Widget _colorOption(BuildContext context, int index, String label, Color color, Color iconColor) {
    final isSelected = _selectedColor == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = index),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: isSelected ? Border.all(color: Theme.of(context).primaryColor, width: 2) : null,
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.grey.withOpacity(0.5)),
                gradient: index == 2 ? const LinearGradient(colors: [Colors.white, Colors.black]) : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Theme.of(context).primaryColor : null)),
          ],
        ),
      ),
    );
  }
}
