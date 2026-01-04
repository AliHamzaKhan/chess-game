import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/game_controller.dart';
import '../utils/assets.dart';
import 'package:chess/chess.dart' as chess_lib;

class ChessBoardWidget extends StatelessWidget {
  final GameController controller = Get.find();

  ChessBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Column(
        children: List.generate(8, (rankIndex) {
          return Expanded(
            child: Row(
              children: List.generate(8, (fileIndex) {
                 final squareName = getSquareName(rankIndex, fileIndex);
                 final isBlackSquare = (rankIndex + fileIndex) % 2 == 1;
                 
                 // Premium Board Colors
                 final whiteSquareColor = const Color(0xFFEEEED2);
                 final blackSquareColor = const Color(0xFF769656);
                 
                 return Expanded(
                   child: Obx(() {
                     // Force rebuild when chess state changes
                     // ignore: unused_local_variable
                     final fen = controller.fen.value;
                     
                     final piece = controller.chess.get(squareName);
                     final isSelected = controller.selectedSquare.value == squareName;
                     final isValidMove = controller.validMoves.contains(squareName);
                     
                     // Highlight Colors
                     final baseColor = isBlackSquare ? blackSquareColor : whiteSquareColor;
                     Color displayColor = baseColor;
                     
                     if (isSelected) {
                         displayColor = const Color(0xFFBBCB2B); // Yellowish highlight
                     } else if (isValidMove) {
                         // Valid move dot or overlay is better, but full square is easiest for now
                         // Use a mix
                         // We will implement overlay dot below, so keep base color or slight tint
                     }
                     
                     // Check if this square is the King in Check? (Advanced, not implemented yet in Controller easy getter)
                     
                     return DragTarget<String>(
                       onWillAccept: (fromSquare) => true,
                       onAccept: (fromSquare) {
                           controller.makeMove(fromSquare, squareName);
                       },
                       builder: (context, candidateData, rejectedData) {
                         return GestureDetector(
                           onTap: () => controller.onSquareTap(squareName),
                           child: Container(
                             color: displayColor,
                             child: Stack(
                                 children: [
                                     // Piece
                                     Center(
                                       child: piece != null 
                                         ? Draggable<String>(
                                             data: squareName,
                                             feedback: SizedBox(
                                                 width: 50, 
                                                 height: 50, 
                                                 child: _buildPiece(getPieceChar(piece.type), piece.color)
                                             ),
                                             childWhenDragging: Opacity(
                                                 opacity: 0.3, 
                                                 child: _buildPiece(getPieceChar(piece.type), piece.color)
                                             ),
                                             child: _buildPiece(getPieceChar(piece.type), piece.color),
                                         )
                                         : null,
                                     ),
                                     
                                     // Valid Move Indicator
                                     if (isValidMove)
                                         Center(
                                             child: Container(
                                                 width: 20, height: 20,
                                                 decoration: BoxDecoration(
                                                     color: Colors.black.withOpacity(0.2),
                                                     shape: BoxShape.circle,
                                                 ),
                                             ),
                                         ),
                                         
                                     // Candidates Drag Hover
                                     if (candidateData.isNotEmpty)
                                          Container(color: Colors.white.withOpacity(0.5)),
                                          
                                     // Rank/File Labels (Coordinates)
                                     if (fileIndex == 0) // Rank numbers on left
                                         Positioned(
                                             top: 2, left: 2,
                                             child: Text("${8 - rankIndex}", 
                                                 style: TextStyle(
                                                     fontSize: 10, 
                                                     color: isBlackSquare ? whiteSquareColor : blackSquareColor,
                                                     fontWeight: FontWeight.bold
                                                 )
                                             ),
                                         ),
                                     if (rankIndex == 7) // File letters on bottom
                                         Positioned(
                                             bottom: 1, right: 2,
                                             child: Text(String.fromCharCode('a'.codeUnitAt(0) + fileIndex), 
                                                 style: TextStyle(
                                                     fontSize: 10,
                                                     color: isBlackSquare ? whiteSquareColor : blackSquareColor,
                                                     fontWeight: FontWeight.bold
                                                 )
                                             ),
                                         ),
                                 ],
                             ),
                           ),
                         );
                       },
                     );
                   }),
                 );
              }),
            ),
          );
        }),
      ),
    );
  }
  
  String getSquareName(int rankIndex, int fileIndex) {
      return '${String.fromCharCode('a'.codeUnitAt(0) + fileIndex)}${8 - rankIndex}';
  }

  String getPieceChar(chess_lib.PieceType type) {
      switch (type) {
        case chess_lib.PieceType.PAWN: return 'p';
        case chess_lib.PieceType.KNIGHT: return 'n';
        case chess_lib.PieceType.BISHOP: return 'b';
        case chess_lib.PieceType.ROOK: return 'r';
        case chess_lib.PieceType.QUEEN: return 'q';
        case chess_lib.PieceType.KING: return 'k';
        default: return 'p';
      }
  }

  Widget _buildPiece(String type, chess_lib.Color color) {
       String key = type; 
       if (color == chess_lib.Color.WHITE) {
           key = key.toUpperCase();
       }
       return Padding(
           padding: const EdgeInsets.all(2.0),
           child: SvgPicture.network(Assets.pieces[key]!),
       );
  }
}
