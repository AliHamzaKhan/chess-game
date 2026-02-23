class Puzzle {
  final String id;
  final String fen; // starting position
  final List<String> solutionMoves; // list of UCI moves e.g. "e2e4"
  final String description; // short description like "Mate in 2"
  final String turn; // "w" or "b" indicating who to move

  Puzzle({
    required this.id,
    required this.fen,
    required this.solutionMoves,
    required this.description,
    required this.turn,
  });
}
