import '../models/puzzle.dart';
import 'package:flutter/material.dart';

class PuzzleService {
  // Mock puzzles – replace with API/Firestore later
  static List<Puzzle> getPuzzles() {
    return [
      Puzzle(
        id: 'p1',
        fen: 'r1bqkbnr/pppp1ppp/2n5/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 2 3',
        solutionMoves: ['f3g5', 'd8h4'], // simple mate in 2 example
        description: 'Mate in 2',
        turn: 'w',
      ),
      Puzzle(
        id: 'p2',
        fen: 'rnbqkb1r/pppp1ppp/5n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 2 3',
        solutionMoves: ['c4f7'],
        description: 'Mate in 1',
        turn: 'w',
      ),
    ];
  }
}
