import 'package:chess_game_flutter/components/pieces.dart';
import 'package:chess_game_flutter/values/colors.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  final void Function()? onTap;
  final bool isValidMove;
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;

  const Square(
      {super.key,
      required this.onTap,
      required this.isValidMove,
      required this.isWhite,
      required this.piece,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    Color? squaredColor;
    if (isSelected) {
      squaredColor = Colors.green;
    } else if (isValidMove) {
      squaredColor = Colors.green[300];
    } else {
      squaredColor = isWhite ? backgroundColor : foregroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
          color: squaredColor,
          child: piece != null
              ? Image.asset(
                  piece!.imagePath,
                )
              : null),
    );
  }
}
