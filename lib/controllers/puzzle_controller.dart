import 'package:get/get.dart';
import '../models/puzzle.dart';
import '../services/puzzle_service.dart';
import 'package:chess/chess.dart' as chess_lib;

class PuzzleController extends GetxController {
  final RxList<Puzzle> puzzles = <Puzzle>[].obs;
  final Rx<Puzzle?> currentPuzzle = Rx<Puzzle?>(null);
  final RxBool solved = false.obs;
  late chess_lib.Chess _chess;

  @override
  void onInit() {
    super.onInit();
    _chess = chess_lib.Chess(); // Default initialization
    loadPuzzles();
    if (puzzles.isNotEmpty) selectPuzzle(puzzles.first.id);
  }

  void loadPuzzles() {
    puzzles.assignAll(PuzzleService.getPuzzles());
  }

  void selectPuzzle(String id) {
    final p = puzzles.firstWhereOrNull((e) => e.id == id);
    if (p != null) {
      currentPuzzle.value = p;
      _chess = chess_lib.Chess.fromFEN(p.fen);
      solved.value = false;
    }
  }

  // Returns true if move was legal and applied.
  bool makeMove(String from, String to) {
    final moveResult = _chess.move({'from': from, 'to': to});
    if (moveResult == false) return false;
    // Since moveResult is a bool, we construct the made string from parameters
    final made = '${from}${to}';
    if (currentPuzzle.value != null && currentPuzzle.value!.solutionMoves.isNotEmpty) {
      final expected = currentPuzzle.value!.solutionMoves.first;
      if (made == expected) {
        // correct move, remove it from solution list
        currentPuzzle.value!.solutionMoves.removeAt(0);
        if (currentPuzzle.value!.solutionMoves.isEmpty) {
          solved.value = true;
        }
      } else {
        // wrong move – could handle penalty
      }
    }
    return true;
  }

  String? get nextHint {
    if (currentPuzzle.value == null) return null;
    if (currentPuzzle.value!.solutionMoves.isEmpty) return null;
    return currentPuzzle.value!.solutionMoves.first;
  }
}
