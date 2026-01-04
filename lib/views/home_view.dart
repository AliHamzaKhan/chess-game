import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../services/auth_service.dart';
import '../services/matchmaking_service.dart';
import '../controllers/theme_controller.dart';
import '../services/firestore_service.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/glass_container.dart';

class HomeView extends StatelessWidget {
  final AuthService auth = Get.find<AuthService>();
  final ThemeController themeController = Get.find<ThemeController>();
  final FirestoreService db = Get.find<FirestoreService>();
  final GameController gameController = Get.find<GameController>();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              "Start Playing", 
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  _buildMenuCard(
                    context, 
                    'Play vs Bot', 
                    'Improve your skills',
                    Icons.smart_toy_outlined, 
                    Colors.cyan,
                    () => _showBotDifficultyDialog(context),
                  ),
                  _buildMenuCard(
                    context, 
                    'Matchmaking', 
                    'Find an opponent',
                    Icons.public, 
                    Colors.orange,
                    () => _startMatchmaking(),
                  ),
                  _buildMenuCard(
                    context, 
                    'Play Friend', 
                    'Challenge by ID',
                    Icons.people_outline, 
                    Colors.green,
                    () => _showFriendDialog(context),
                  ),
                  _buildMenuCard(
                    context, 
                    'Leaderboard', 
                    'Global Rankings',
                    Icons.emoji_events_outlined, 
                    Colors.purple,
                    () => Get.toNamed('/leaderboard'),
                  ),
                  _buildMenuCard(
                    context, 
                    'Friends', 
                    'Manage friends',
                    Icons.people_alt_outlined, 
                    Colors.pinkAccent,
                    () => Get.toNamed('/friends'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color?.withOpacity(0.5),
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
         children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    Get.toNamed('/profile');
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                         "Welcome back,",
                         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)
                         ),
                       ),
                       Obx(() => Text(
                         auth.appUser.value?.username ?? "Player",
                         style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                       )),
                    ],
                  ),
                ),
                Row(
                   children: [
                      IconButton(
                        icon: Obx(() => Icon(themeController.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined)),
                        onPressed: themeController.toggleTheme,
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        onPressed: auth.signOut,
                      ),
                   ],
                )
              ],
            ),
            const SizedBox(height: 24),
            _buildStatBar(context),
         ],
      ),
    );
  }
  
  Widget _buildStatBar(BuildContext context) {
     return Obx(() {
        final user = auth.appUser.value;
        return GlassContainer(
           opacity: 0.1,
           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
           child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                 _statItem(context, "Level", "${user?.level ?? 1}"),
                 _verticalDivider(context),
                 _statItem(context, "Points", "${user?.points ?? 1000}"),
                 _verticalDivider(context),
                 _statItem(context, "Wins", "${user?.wins ?? 0}"),
              ],
           ),
        );
     });
  }
  
  Widget _verticalDivider(BuildContext context) {
     return Container(
       height: 30, width: 1, 
       color: Theme.of(context).dividerColor.withOpacity(0.3)
     );
  }
  
  Widget _statItem(BuildContext context, String label, String value) {
     return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
           Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
        ],
     );
  }

  Widget _buildMenuCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        opacity: isDark ? 0.3 : 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          ],
        ),
      ),
    );
  }


  void _showBotDifficultyDialog(BuildContext context) {
    Get.bottomSheet(
       Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
             color: Theme.of(context).scaffoldBackgroundColor,
             borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                const Text("Select Difficulty", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                _difficultyOption(context, "Easy", Colors.green, BotDifficulty.easy),
                _difficultyOption(context, "Medium", Colors.orange, BotDifficulty.medium),
                _difficultyOption(context, "Hard", Colors.red, BotDifficulty.hard),
             ],
          ),
       ),
    );
  }
  
  Widget _difficultyOption(BuildContext context, String label, Color color, BotDifficulty difficulty) {
      return ListTile(
         leading: Icon(Icons.psychology, color: color),
         title: Text(label),
         onTap: () {
             Get.back();
             _startBotGame(difficulty);
         },
      );
  }

  void _startBotGame(BotDifficulty difficulty) {
    gameController.startGame(mode: GameMode.bot, difficulty: difficulty);
    Get.toNamed('/game');
  }

  void _startMatchmaking() {
     Get.find<MatchmakingService>().findMatch();
  }
  
  void _showFriendDialog(BuildContext context) {
      final textController = TextEditingController();
      Get.defaultDialog(
          title: "Play with Friend",
          content: Column(
            children: [
               const Text("Ask your friend for their User ID found in their Profile."),
               const SizedBox(height: 10),
               TextField(
                  controller: textController, 
                  decoration: const InputDecoration(
                      hintText: "Enter Opponent ID",
                      border: OutlineInputBorder(),
                  ),
              ),
            ],
          ),
          confirm: ElevatedButton(
              onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                      Get.back();
                      Get.find<MatchmakingService>().sendChallenge(textController.text.trim());
                  }
              }, 
              child: const Text("Challenge")
          ),
          cancel: TextButton(onPressed: () => Get.back(), child: const Text("Cancel"))
      );
  }
}
