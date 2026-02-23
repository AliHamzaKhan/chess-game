import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/puzzle_controller.dart';
import '../widgets/glass_container.dart';
import '../widgets/chess_board_widget.dart';

class PuzzleView extends StatelessWidget {
  const PuzzleView({super.key});

  @override
  Widget build(BuildContext context) {
    final PuzzleController controller = Get.put(PuzzleController());
    final TextEditingController moveInput = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Puzzle", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text("12", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: Obx(() {
        final puzzle = controller.currentPuzzle.value;
        if (puzzle == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            const SizedBox(height: 20),
            Text(puzzle.description,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const Text("White to move"),
            const SizedBox(height: 30),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ChessBoardWidget(), // static visual board
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  TextField(
                    controller: moveInput,
                    decoration: const InputDecoration(
                      labelText: "Your move (e2e4)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final hint = controller.nextHint;
                            if (hint != null) {
                              Get.snackbar('Hint', hint);
                            } else {
                              Get.snackbar('Hint', 'No hint available');
                            }
                          },
                          icon: const Icon(Icons.lightbulb_outline),
                          label: const Text("Hint"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.withOpacity(0.2),
                            foregroundColor: Colors.orange,
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final input = moveInput.text.trim();
                            if (input.length == 4) {
                              final from = input.substring(0, 2);
                              final to = input.substring(2, 4);
                              final ok = controller.makeMove(from, to);
                              if (ok) {
                                if (controller.solved.value) {
                                  Get.snackbar('Correct!', 'Puzzle solved!');
                                } else {
                                  Get.snackbar('Move accepted', 'Continue solving');
                                }
                              } else {
                                Get.snackbar('Invalid', 'Illegal move');
                              }
                            } else {
                              Get.snackbar('Error', 'Enter move in UCI format (e2e4)');
                            }
                          },
                          icon: const Icon(Icons.check),
                          label: const Text("Submit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
