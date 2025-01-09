import 'package:flutter/material.dart';

import 'components/dead_piece.dart';
import 'components/pieces.dart';
import 'components/square.dart';
import 'helper/helper_function.dart';

class BoardGame extends StatefulWidget {
  const BoardGame({Key? key}) : super(key: key);

  @override
  State<BoardGame> createState() => _BoardGameState();
}

class _BoardGameState extends State<BoardGame> {
  late List<List<ChessPiece?>> board;
  // The currently selected piece on the chess board,
// If no piece is selected, this is null.
  ChessPiece? selectedPiece;
// The row index of the selected piece
// Default value -1 indicated no piece is currently selected;
  int selectedRow = -1;

// The Column index of the selected piece
// Default value -1 indicated no piece is currently selected;
  int selectedCol = -1;
  List<List<int>> validMoves = [];

  List<ChessPiece> whitePiecesTaken = [];

  List<ChessPiece> blackPiecesTaken = [];

  bool isWhiteTurn = true;

  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    // initialize the board with nulls, meaning no pieces in those positions.
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPiecesType.pawn,
        isWhite: false,
        imagePath: 'images/blackPawn.png',
      );

      newBoard[6][i] = ChessPiece(
        type: ChessPiecesType.pawn,
        isWhite: true,
        imagePath: 'images/whitePawn.png',
      );
    }

    // Place rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPiecesType.rook,
        isWhite: false,
        imagePath: "images/blackPawn.png");
    newBoard[0][7] = ChessPiece(
        type: ChessPiecesType.rook,
        isWhite: false,
        imagePath: "images/blackTower.png");
    newBoard[7][0] = ChessPiece(
        type: ChessPiecesType.rook,
        isWhite: true,
        imagePath: "images/whiteTower.png");
    newBoard[7][7] = ChessPiece(
        type: ChessPiecesType.rook,
        isWhite: true,
        imagePath: "images/whiteTower.png");

    // Place knights
    newBoard[0][1] = ChessPiece(
        type: ChessPiecesType.knight,
        isWhite: false,
        imagePath: "images/blackKnight.png");
    newBoard[0][6] = ChessPiece(
        type: ChessPiecesType.knight,
        isWhite: false,
        imagePath: "images/blackKnight.png");
    newBoard[7][1] = ChessPiece(
        type: ChessPiecesType.knight,
        isWhite: true,
        imagePath: "images/whiteKnight.png");
    newBoard[7][6] = ChessPiece(
        type: ChessPiecesType.knight,
        isWhite: true,
        imagePath: "images/whiteKnight.png");

    // Place bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPiecesType.bishop,
        isWhite: false,
        imagePath: "images/blackBishop.png");

    newBoard[0][5] = ChessPiece(
        type: ChessPiecesType.bishop,
        isWhite: false,
        imagePath: "images/blackBishop.png");
    newBoard[7][2] = ChessPiece(
        type: ChessPiecesType.bishop,
        isWhite: true,
        imagePath: "images/whiteBishop.png");
    newBoard[7][5] = ChessPiece(
        type: ChessPiecesType.bishop,
        isWhite: true,
        imagePath: "images/whiteBishop.png");

    // Place queens
    newBoard[0][3] = ChessPiece(
      type: ChessPiecesType.queen,
      isWhite: false,
      imagePath: 'images/blackQueen.png',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPiecesType.queen,
      isWhite: true,
      imagePath: 'images/whiteQueen.png',
    );

    // Place kings
    newBoard[0][4] = ChessPiece(
      type: ChessPiecesType.king,
      isWhite: false,
      imagePath: 'images/blackKing.png',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPiecesType.king,
      isWhite: true,
      imagePath: 'images/WhiteKing.png',
    );

    board = newBoard;
  }

// USER SELECTED A PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      validMoves = calculateRealValidMoves(
          selectedRow, selectedCol, selectedPiece, true);
    });
  }

  List<List<int>> calculateRowValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPiecesType.pawn:
      case ChessPiecesType.pawn:
        // Check the square immediately in front of the pawn
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // If it's the pawn's first move (row is either 1 for black pawns or 6 for white ones), check the square two steps ahead
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // Check for possible captures
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;

      case ChessPiecesType.rook:
        // horizontal and vertical directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], //left
          [0, 1], //right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves
                    .add([newRow, newCol]); // can capture opponent's piece
              }
              break; // blocked by own piece or after capturing
            }
            candidateMoves.add([newRow, newCol]); // an empty valid square
            i++;
          }
        }
        break;

      case ChessPiecesType.knight:
        // all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          // if the new position is empty or there is an opponent's piece there
          if (board[newRow][newCol] == null ||
              board[newRow][newCol]!.isWhite != piece.isWhite) {
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;

      case ChessPiecesType.bishop:
        // diagonal directions
        var directions = [
          [-1, -1], // up-left
          [-1, 1], // up-right
          [1, -1], // down-left
          [1, 1], // down-right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPiecesType.queen:
        // Queen can move in any direction, combining the moves of a rook and a bishop
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up-left
          [-1, 1], // up-right
          [1, -1], // down-left
          [1, 1] // down-right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]); // free space
            i++;
          }
        }
        break;

      case ChessPiecesType.king:
        var kingMoves = [
          [-1, -1], // Up-left
          [-1, 0], // Up
          [-1, 1], // Up-right
          [0, -1], // Left
          [0, 1], // Right
          [1, -1], // Down-left
          [1, 0], // Down
          [1, 1] // Down-right
        ];

        for (var move in kingMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // Can capture
            }
            continue; // Square is blocked by a piece of the same color
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;

      default:
    }
    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRowValidMoves(row, col, piece);

    // Não verifica se o movimento deixa o rei seguro
    if (checkSimulation) {
      realValidMoves = candidateMoves;
    } else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  void movePiece(int newRow, int newCol) {
// if the new spot has an enemy piece
    if (board[newRow][newCol] != null) {
// add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    if (selectedPiece?.type == ChessPiecesType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    checkStatus = isKingInCheck(!isWhiteTurn);

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("CHECK MATE"),
                actions: [
                  TextButton(
                      onPressed: resetGame, child: Text("Restart The Game"))
                ],
              ));
    }

    isWhiteTurn = !isWhiteTurn;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.isWhite != isWhiteKing) {
          List<List<int>> opponentMoves =
              calculateRowValidMoves(row, col, piece);
          for (var move in opponentMoves) {
            if (move[0] == kingPosition[0] && move[1] == kingPosition[1]) {
              return true; // Rei está em "check".
            }
          }
        }
      }
    }
    return false; // Rei não está em "check".
  }

  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    ChessPiece? originalDestination = board[endRow][endCol];
    List<int> originalKingPosition = piece.type == ChessPiecesType.king
        ? (piece.isWhite ? whiteKingPosition : blackKingPosition)
        : [];

    // Simula o movimento.
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    if (piece.type == ChessPiecesType.king) {
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    bool isSafe = !isKingInCheck(piece.isWhite);

    // Reverte a simulação.
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestination;

    if (piece.type == ChessPiecesType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition;
      } else {
        blackKingPosition = originalKingPosition;
      }
    }

    return isSafe;
  }

  bool isCheckMate(bool isWhiteKing) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece != null && piece.isWhite == isWhiteKing) {
          List<List<int>> validMoves =
              calculateRealValidMoves(row, col, piece, true);
          for (var move in validMoves) {
            int endRow = move[0];
            int endCol = move[1];
            if (simulatedMoveIsSafe(piece, row, col, endRow, endCol)) {
              return false; // Existe um movimento que evita o "checkmate".
            }
          }
        }
      }
    }
    return true; // Nenhum movimento válido -> "checkmate".
  }

  void resetGame() {
    Navigator.pop(context);
    _initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    isWhiteTurn = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: whitePiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ), // GridView.builder
          ), // Expanded
          Text(checkStatus ? "CHECK" : ""),
          Expanded(
            flex: 3,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8 * 8,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;

                bool isSelected = selectedCol == col && selectedRow == row;
                bool isValidMove = false;
                for (var position in validMoves) {
                  // compare row and col
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                  isSelected: isSelected,
                  isWhite: isWhite(index),
                  piece: board[row][col],
                );
              },
            ),
          ),

          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blackPiecesTaken.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ), // GridView.builder
          ), // Expanded
        ],
      ),
    );
  }
}
