import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../widgets/chess_board_widget.dart';
import '../services/auth_service.dart';
import '../widgets/background_scaffold.dart';
import '../widgets/glass_container.dart';
import '../widgets/move_history_sheet.dart';
import '../widgets/captured_pieces_widget.dart';

class GameView extends StatelessWidget {
  final GameController controller = Get.find();
  final AuthService auth = Get.find<AuthService>();

  GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (backPressResult, result) async {
         if (backPressResult) return;
         await controller.exitGame();
      },
      child: BackgroundScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => controller.exitGame(),
          ),
          title: Obx(() {
             String mode = "Unknown";
             if (controller.currentMode == GameMode.online) mode = "Ranked";
             else if (controller.currentMode == GameMode.bot) mode = "vs Computer";
             else mode = "Pass & Play";
             return Column(
               children: [
                 Text(mode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 if (controller.currentMode == GameMode.online || controller.currentMode == GameMode.bot)
                    const Text("BLITZ • 10 MIN", style: TextStyle(fontSize: 10, color: Colors.grey))
               ],
             );
          }),
          centerTitle: true,
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

              const SizedBox(height: 16),
              
              // Move History Line
              _buildMoveHistoryLine(context),

              const SizedBox(height: 16),

              // Bottom Controls
              _buildBottomControls(context),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(bool isMe, BuildContext context) {
    return Obx(() {
      String name = "Unknown";
      int timeMs = 0;
      bool isTurn = false;
      int rating = 1200;
      String rowColor = 'w';

      // --- Determine Row Color & Basic Info ---
      if (controller.currentMode == GameMode.local) {
         // Local Pass & Play: Bottom (isMe=true) is usually White for simplicity in this MVP, 
         // or we can say P1 vs P2. Let's assume Bottom=White, Top=Black.
         rowColor = isMe ? 'w' : 'b';
         name = isMe ? "White" : "Black";
         timeMs = isMe ? controller.whiteTime.value : controller.blackTime.value;
         isTurn = isMe ? controller.currentTurn.value == 'w' : controller.currentTurn.value == 'b';
      } 
      else if (controller.currentMode == GameMode.bot) {
         // Bot Game
         String myC = controller.myColor ?? 'w';
         rowColor = isMe ? myC : (myC == 'w' ? 'b' : 'w');
         
         if (isMe) {
            name = "You";
            rating = auth.appUser.value?.elo ?? 1200;
         } else {
            name = "Bot (${controller.botDifficulty.name})";
            rating = 1000 + (controller.botDifficulty.index * 400); 
         }
         timeMs = rowColor == 'w' ? controller.whiteTime.value : controller.blackTime.value;
         bool isWhiteTurn = controller.currentTurn.value == 'w';
         isTurn = (rowColor == 'w' && isWhiteTurn) || (rowColor == 'b' && !isWhiteTurn);
      }
      else {
         // Online Game
         final game = controller.gameModel.value;
         if (game != null) {
            String myC = controller.myColor ?? 'w';
            rowColor = isMe ? myC : (myC == 'w' ? 'b' : 'w');
            
            if (rowColor == 'w') {
               name = game.whitePlayerName;
               // Setup opponent rating if available, else mock
            } else {
               name = game.blackPlayerName;
            }
            
            timeMs = rowColor == 'w' ? controller.whiteTime.value : controller.blackTime.value;
            isTurn = game.currentTurn == rowColor;
         }
         if (isMe) rating = auth.appUser.value?.elo ?? 1200;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Expanded(
             child: Row(
               children: [
                 Stack(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(2),
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         border: isTurn ? Border.all(color: Colors.green, width: 2) : null,
                       ),
                       child: CircleAvatar(
                         radius: 20,
                         backgroundColor: Colors.grey.withOpacity(0.2),
                         backgroundImage: isMe 
                             ? const AssetImage('assets/avatars/avatar1.png') 
                             : (controller.currentMode == GameMode.bot ? const AssetImage('assets/avatars/alice.png') : null),
                         child: (controller.currentMode != GameMode.bot && !isMe) ? const Icon(Icons.person) : null,
                       ),
                     ),
                     if (isTurn)
                       Positioned(bottom: 0, right: 0, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2))))
                   ]
                 ),
                 const SizedBox(width: 12),
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                     Text("Rating: $rating", style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                   ],
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                    child: SingleChildScrollView(
                       scrollDirection: Axis.horizontal,
                       child: CapturedPiecesWidget(
                           capturedPieces: rowColor == 'w' ? controller.whiteCaptured : controller.blackCaptured,
                           areWhitePieces: rowColor == 'b',
                       ),
                    ),
                 ),
               ]
             ),
           ),
           const SizedBox(width: 8),
           _buildTimer(timeMs, isTurn, context),
        ],
      );
    });
  }

  Widget _buildTimer(int ms, bool isTurn, BuildContext context) {
      if (ms < 0) ms = 0;
      int seconds = (ms / 1000).floor();
      int minutes = (seconds / 60).floor();
      int remainingSeconds = seconds % 60;
      String text = "${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}";

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isTurn ? const Color(0xFF2E2E2E) : const Color(0xFF1E1E1E), // Dark timer bg
          borderRadius: BorderRadius.circular(8),
          border: isTurn ? Border.all(color: Colors.white.withOpacity(0.2)) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Courier',
            color: isTurn ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      );
  }

  Widget _buildMoveHistoryLine(BuildContext context) {
    return Obx(() {
       List<String> history = controller.history;
       if (history.isEmpty) return const SizedBox.shrink();
       
       String lastMove = history.last;
       String secondLast = history.length > 1 ? "${(history.length/2).ceil()}... ${history[history.length-2]}" : "";
       String display = "$secondLast   ${(history.length/2).ceil()}. $lastMove";
       if (history.length % 2 != 0) {
          // White just moved
          display = "${(history.length/2).ceil()}. $lastMove";
       }

       return Container(
         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
         decoration: BoxDecoration(
           color: Theme.of(context).cardTheme.color,
           borderRadius: BorderRadius.circular(12),
         ),
         child: Text(
           display, 
           style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Courier', fontSize: 16, color: Colors.blueAccent)
         ),
       );
    });
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _controlButton(context, Icons.flag_outlined, "Resign", () => controller.resignGame()),
          _controlButton(context, Icons.handshake_outlined, "Draw", () => controller.offerDraw()),
          if (controller.currentMode == GameMode.online) _controlButton(context, Icons.chat_bubble_outline, "Chat", () => Get.toNamed('/chat')),
          _controlButton(context, Icons.lightbulb_outline, "Hint", () => controller.getHint(), isHighlight: true),
        ],
      ),
    );
  }

  Widget _controlButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool isHighlight = false}) {
     return InkWell(
       onTap: onTap,
       borderRadius: BorderRadius.circular(12),
       child: Container(
         width: 70,
         height: 70,
         decoration: BoxDecoration(
           color: isHighlight ? const Color(0xFF4F46E5) : Theme.of(context).cardTheme.color,
           borderRadius: BorderRadius.circular(16),
         ),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(icon, color: isHighlight ? Colors.white : Theme.of(context).iconTheme.color),
             const SizedBox(height: 4),
             Text(label, style: TextStyle(fontSize: 10, color: isHighlight ? Colors.white : Theme.of(context).hintColor, fontWeight: FontWeight.bold)),
           ],
         ),
       ),
     );
  }
}
