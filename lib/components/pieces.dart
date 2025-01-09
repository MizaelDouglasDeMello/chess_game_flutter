enum ChessPiecesType { pawn, knight, bishop, rook, queen, king }

class ChessPiece {
  final ChessPiecesType type;
  final bool isWhite;
  final String imagePath;

  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.imagePath,
  });
}
