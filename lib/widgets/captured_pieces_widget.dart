import 'package:flutter/material.dart';
import '../utils/assets.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final List<String> capturedPieces;
  final bool areWhitePieces; // If true, display White icons (e.g. 'P', 'N'), else Black ('p', 'n')

  const CapturedPiecesWidget({
    super.key,
    required this.capturedPieces,
    required this.areWhitePieces,
  });

  @override
  Widget build(BuildContext context) {
    if (capturedPieces.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: capturedPieces.map((type) {
        // type is always lowercase 'p', 'n', etc. from our controller logic
        // If we want to show White pieces, we uppercase it to match Assets keys 'P', 'N'
        String assetKey = areWhitePieces ? type.toUpperCase() : type.toLowerCase();
        String? url = Assets.pieces[assetKey];
        
        if (url == null) return const SizedBox.shrink();

        // Overlap effect
        return Align(
          widthFactor: 0.6, 
          child: Image.asset(
            url,
            width: 20,
            height: 20,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 20, height: 20, 
              color: Colors.transparent
            ),
          ),
        );
      }).toList(),
    );
  }
}

