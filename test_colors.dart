import 'package:chess/chess.dart' as chess_lib;
void main() {
  print(chess_lib.Color.WHITE);
  print(chess_lib.Color.BLACK);
  var game = chess_lib.Chess();
  print(game.get('e2')?.color == chess_lib.Color.WHITE);
  print(game.get('e7')?.color == chess_lib.Color.BLACK);
  print(game.get('e7')?.color == chess_lib.Color.WHITE);
  print(game.get('e7')?.color);
}
