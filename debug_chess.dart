import 'package:chess/chess.dart' as chess_lib;
void main() {
  var game = chess_lib.Chess();
  var bp = game.get('e7')!;
  var wp = game.get('e2')!;
  print('bp type: ${bp.type}, type type: ${bp.type.runtimeType}');
  print('bp color: ${bp.color}, color type: ${bp.color.runtimeType}');
  print('wp type: ${wp.type}, type type: ${wp.type.runtimeType}');
  print('wp color: ${wp.color}, color type: ${wp.color.runtimeType}');
  print('wp.color == WHITE: ${wp.color == chess_lib.Color.WHITE}');
  print('bp.color == BLACK: ${bp.color == chess_lib.Color.BLACK}');
}
