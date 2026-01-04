
import 'package:chess/chess.dart';

void main() {
  final chess = Chess();
  chess.move('e4');
  print('PGN: ${chess.pgn()}');
  // print('Item: ${chess.history.first.move.san}'); // This failed before
  try {
      print((chess.history.first as dynamic).move.san);
  } catch(e) { print("No move.san"); }
  
  try {
      print((chess.history.first as dynamic).san);
  } catch(e) { print("No state.san"); }
}
