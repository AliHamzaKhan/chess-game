import 'package:chess/chess.dart' as chess_lib;
void main() {
  var game = chess_lib.Chess();
  print(game.get('e2')?.type);
}
