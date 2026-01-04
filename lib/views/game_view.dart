import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../widgets/chess_board_widget.dart';
import '../services/auth_service.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/glass_container.dart';
import '../widgets/move_history_sheet.dart';

class GameView extends StatelessWidget {
  final GameController controller = Get.find();
  final AuthService auth = Get.find<AuthService>();

  GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // disables default back behavior
      onPopInvokedWithResult: (backPressResult, _) async {
        // Call controller exit function
        await controller.exitGame();
      },
      child: BackgroundScaffold(
        appBar: AppBar(
          title: const Text("Chess Master"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
              IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: "Move History",
                  onPressed: () {
                      Get.bottomSheet(
                          MoveHistorySheet(),
                          isScrollControlled: true,
                          enableDrag: true
                      );
                  },
              ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Opponent info area
              Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: _buildPlayerInfo(false, context),
              ),

              const Spacer(),

              // Board
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GlassContainer(
                   padding: const EdgeInsets.all(4),
                   borderRadius: BorderRadius.circular(8),
                   color: Colors.white.withOpacity(0.05),
                   child: ClipRRect(
                       borderRadius: BorderRadius.circular(4),
                       child: ChessBoardWidget(),
                   ),
                ),
              ),

              const Spacer(),

              // My info area
              Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                 child: _buildPlayerInfo(true, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(bool isMe, BuildContext context) {
    return Obx(() {
      String name = "";
      int timeMs = 0;
      bool isTurn = false;
      bool showingWhite = true;

      // --- Local / Bot game ---
      if (controller.currentMode == GameMode.local || controller.currentMode == GameMode.bot) {
        name = isMe ? "You" : (controller.currentMode == GameMode.bot ? "Bot" : "Opponent");
        timeMs = isMe ? controller.whiteTime.value : controller.blackTime.value;
        showingWhite = isMe; // Me = White, Opponent/Bot = Black
        isTurn = isMe ? controller.currentTurn.value == 'w' : controller.currentTurn.value == 'b';
      }
      // --- Online / 1v1 game ---
      else {
        final game = controller.gameModel.value;
        if (game == null) return const SizedBox.shrink();

        final myColor = controller.myColor ?? 'w'; // Default to 'w'
        final opponentColor = myColor == 'w' ? 'b' : 'w';

        // Determine which color this row represents
        String rowColor = isMe ? myColor : opponentColor;

        // Correctly assign name
        if (controller.currentMode == GameMode.bot && !isMe) {
          name = "Bot";
        } else if (rowColor == 'w') {
          name = game.whitePlayerName;
        } else {
          name = game.blackPlayerName;
        }

        // Timer
        timeMs = rowColor == 'w' ? controller.whiteTime.value : controller.blackTime.value;

        // Turn
        isTurn = game.currentTurn == rowColor;

        // For avatar/piece color
        showingWhite = rowColor == 'w';
      }

      return AnimatedScale(
        scale: isTurn ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isTurn
                ? Theme.of(context).primaryColor.withOpacity(0.25)
                : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isTurn ? Theme.of(context).primaryColor : Colors.white.withOpacity(0.1),
              width: isTurn ? 2.5 : 1,
            ),
            boxShadow: isTurn
                ? [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 1,
              )
            ]
                : [],
          ),
          child: Row(
            children: [
              // Color Indicator / Avatar
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(color: showingWhite ? Colors.white : Colors.black, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade300,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "?",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                      ),
                    ),
                  ),
                  // Small piece indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: showingWhite ? Colors.white : Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe ? "You" : name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isTurn)
                      Row(
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Theme.of(context).colorScheme.secondary),
                          ),
                          const SizedBox(width: 6),
                          Text(isMe ? "Your Turn" : "Their Turn",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )
                    else
                      Text(showingWhite ? "Playing as White" : "Playing as Black",
                          style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              _buildTimer(timeMs, isTurn, context),
            ],
          ),
        ),
      );
    });
  }


  Widget _buildTimer(int ms, bool isTurn, BuildContext context) {
      if (ms < 0) ms = 0;
      int seconds = (ms / 1000).floor();
      int minutes = (seconds / 60).floor();
      int remainingSeconds = seconds % 60;

      String text = "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";

      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isTurn
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          boxShadow: isTurn
              ? [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              blurRadius: 12,
              spreadRadius: 1,
            )
          ]
              : [],
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Courier',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
  }
}
