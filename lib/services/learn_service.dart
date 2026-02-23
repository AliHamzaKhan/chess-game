import 'package:flutter/material.dart';

import '../models/lesson.dart';

class LearnService {
  // Static mock data for lessons
  static List<Lesson> getLessons() {
    return [
      Lesson(
        id: 'development',
        title: 'Piece Development',
        subtitle: 'Activate your pieces efficiently',
        description: 'Learn why developing pieces quickly is critical in chess.',
        content: '''## Development

Bring knights and bishops into the game early.
Avoid moving the same piece repeatedly in the opening.
Connect your rooks after castling.

Well-developed pieces create strong attacks.''',
        iconCodePoint: Icons.trending_up.codePoint,
        colorValue: Colors.indigo.value,
        category: 'Strategy',
      ),

      Lesson(
        id: 'king_safety',
        title: 'King Safety',
        subtitle: 'Protect your most important piece',
        description: 'Understand why king safety is critical.',
        content: '''## King Safety

Castle early.
Avoid weakening pawn structure near your king.
Watch for open files and diagonal attacks.

A safe king means a stronger position.''',
        iconCodePoint: Icons.shield.codePoint,
        colorValue: Colors.teal.value,
        category: 'Strategy',
      ),

      Lesson(
        id: 'pawn_structure',
        title: 'Pawn Structure',
        subtitle: 'The backbone of your position',
        description: 'Learn how pawn weaknesses and strengths affect the game.',
        content: '''## Pawn Structure

Isolated Pawns – No neighboring pawns.
Doubled Pawns – Two pawns on same file.
Passed Pawns – No enemy pawn blocking its path.

Strong pawn structure gives long-term advantage.''',
        iconCodePoint: Icons.grid_on.codePoint,
        colorValue: Colors.brown.value,
        category: 'Strategy',
      ),

      Lesson(
        id: 'endgame_basics',
        title: 'Endgame Basics',
        subtitle: 'Winning simplified positions',
        description: 'Learn key endgame techniques.',
        content: '''## Endgame Basics

Activate your king.
Push passed pawns.
Learn king + rook vs king checkmate.
Opposition is crucial in king and pawn endings.

Endgames decide many games.''',
        iconCodePoint: Icons.hourglass_bottom.codePoint,
        colorValue: Colors.deepPurple.value,
        category: 'Advanced',
      ),

      Lesson(
        id: 'rook_endgames',
        title: 'Rook Endgames',
        subtitle: 'Most common endgames',
        description: 'Master fundamental rook endgame concepts.',
        content: '''## Rook Endgames

Cut off the king.
Activate your rook.
Place rook behind passed pawn.
Learn the Lucena and Philidor positions.

Rook endgames are very practical.''',
        iconCodePoint: Icons.swap_horiz.codePoint,
        colorValue: Colors.blueGrey.value,
        category: 'Advanced',
      ),

      Lesson(
        id: 'calculation',
        title: 'Calculation Skills',
        subtitle: 'Think ahead like a master',
        description: 'Improve your move calculation and visualization.',
        content: '''## Calculation

Look at checks, captures, and threats first.
Calculate forcing moves.
Visualize positions without moving pieces.
Avoid guessing — calculate clearly.

Strong calculation wins games.''',
        iconCodePoint: Icons.psychology.codePoint,
        colorValue: Colors.deepOrange.value,
        category: 'Advanced',
      ),

      Lesson(
        id: 'blunder_avoidance',
        title: 'Avoiding Blunders',
        subtitle: 'Stop losing pieces for free',
        description: 'Learn how to reduce simple mistakes.',
        content: '''## Avoiding Blunders

Before every move ask:
- What is my opponent threatening?
- Is my piece defended?
- Is my king safe?

Slow down. Double-check moves.''',
        iconCodePoint: Icons.warning.codePoint,
        colorValue: Colors.redAccent.value,
        category: 'Fundamentals',
      ),

      Lesson(
        id: 'attacking_king',
        title: 'Attacking the King',
        subtitle: 'Launch powerful attacks',
        description: 'Learn patterns to attack the enemy king.',
        content: '''## King Attack

Bring pieces toward enemy king.
Open files and diagonals.
Sacrifices can open defenses.
Coordinate queen and rook.

Attack with purpose, not randomly.''',
        iconCodePoint: Icons.local_fire_department.codePoint,
        colorValue: Colors.orangeAccent.value,
        category: 'Strategy',
      ),

      Lesson(
        id: 'defense',
        title: 'Defensive Techniques',
        subtitle: 'Survive tough positions',
        description: 'Learn how to defend difficult positions.',
        content: '''## Defense

Trade attacking pieces.
Close open lines.
Create counterplay.
Stay calm under pressure.

Good defense saves games.''',
        iconCodePoint: Icons.security.codePoint,
        colorValue: Colors.greenAccent.value,
        category: 'Strategy',
      ),

      Lesson(
        id: 'chess_notation',
        title: 'Chess Notation',
        subtitle: 'Read and write chess moves',
        description: 'Understand algebraic notation used in chess.',
        content: '''## Algebraic Notation

e4 – Pawn to e4
Nf3 – Knight to f3
O-O – King side castling
O-O-O – Queen side castling
x – Capture
+ – Check
# – Checkmate

Notation helps analyze games.''',
        iconCodePoint: Icons.menu_book.codePoint,
        colorValue: Colors.cyan.value,
        category: 'Fundamentals',
      ),
    ];
  }
}
