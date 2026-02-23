import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chess/chess.dart' as chess_lib;
import '../models/game_model.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/matchmaking_service.dart';

enum GameMode { online, bot, local }

enum BotDifficulty { easy, medium, hard }

class GameController extends GetxController {
  final FirestoreService _db = Get.find<FirestoreService>();
  final AuthService _auth = Get.find<AuthService>();

  late chess_lib.Chess chess;

  // Board State
  RxString fen = ''.obs;
  RxList<String> history = <String>[].obs;
  RxString currentTurn = 'w'.obs;
  RxList<String> validMoves = <String>[].obs;
  Rx<String?> selectedSquare = Rx<String?>(null);
  RxList<String> whiteCaptured = <String>[].obs;
  RxList<String> blackCaptured = <String>[].obs;

  // Time (milliseconds)
  RxInt whiteTime = 600000.obs;
  RxInt blackTime = 600000.obs;

  // Game Meta
  Rx<GameModel?> gameModel = Rx<GameModel?>(null);
  GameMode currentMode = GameMode.local;
  BotDifficulty botDifficulty = BotDifficulty.easy;

  String? gameId;
  String? myColor;

  Timer? _timer;
  StreamSubscription? gameSubscription;

  bool _gameOverHandled = false;
  RxBool moveLocked = false.obs;

  @override
  void onInit() {
    super.onInit();
    chess = chess_lib.Chess(); // Initialize with a default state to prevent LateInitializationError
    _updateState();
  }

  // -------------------- START GAME --------------------

  void startGame({required GameMode mode, GameModel? onlineGame, BotDifficulty? difficulty, String? asColor}) {
    _timer?.cancel();
    gameSubscription?.cancel();
    _gameOverHandled = false;
    moveLocked.value = false;

    currentMode = mode;
    botDifficulty = difficulty ?? BotDifficulty.easy;
    gameModel.value = onlineGame;
    gameId = onlineGame?.id;

    chess = chess_lib.Chess();

    if (onlineGame != null) {
      chess.load(onlineGame.fen);
      myColor = asColor;
      whiteTime.value = onlineGame.whiteTime;
      blackTime.value = onlineGame.blackTime;
      listenToGame();
    } else {
      myColor = asColor ?? 'w';
      whiteTime.value = 600000;
      blackTime.value = 600000;
    }

    _updateState();

    _startLocalTimer();
    
    if (currentMode == GameMode.bot && myColor == 'b') {
        Future.delayed(const Duration(milliseconds: 1000), _botMove);
    }
  }

  // -------------------- TIMER (LOCAL / BOT ONLY) --------------------

  void _startLocalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (chess.game_over || _gameOverHandled) {
        _timer?.cancel();
        return;
      }

      if (currentMode == GameMode.online && gameModel.value != null) {
        final model = gameModel.value!;
        final now = DateTime.now().millisecondsSinceEpoch;
        final elapsed = now - model.lastMoveAt;

        if (chess.turn == chess_lib.Color.WHITE) {
          int remaining = max(0, model.whiteTime - elapsed);
          whiteTime.value = remaining;
          if (remaining <= 0) _handleTimeout('w');
        } else {
          int remaining = max(0, model.blackTime - elapsed);
          blackTime.value = remaining;
          if (remaining <= 0) _handleTimeout('b');
        }
      } else {
        // Local / Bot mode
        if (chess.turn == chess_lib.Color.WHITE) {
          whiteTime.value = max(0, whiteTime.value - 1000);
          if (whiteTime.value <= 0) _handleTimeout('w');
        } else {
          blackTime.value = max(0, blackTime.value - 1000);
          if (blackTime.value <= 0) _handleTimeout('b');
        }
      }
    });
  }

  void _handleTimeout(String color) {
    if (_gameOverHandled) return;
    _timer?.cancel();

    if (currentMode == GameMode.online && gameModel.value != null) {
      final winnerId = color == 'w' ? gameModel.value!.blackPlayerId : gameModel.value!.whitePlayerId;

      _db.updateGame(gameModel.value!.copyWith(status: 'finished', winnerId: winnerId, lastMoveAt: DateTime.now().millisecondsSinceEpoch, whiteTime: whiteTime.value, blackTime: blackTime.value));

      _handleGameOver(winnerId);
    } else {
      _handleGameOver(null);
    }
  }

  // -------------------- ONLINE SYNC --------------------
   // 'w', 'b', or null

  void listenToGame() {
    if (gameId == null) return;

    gameSubscription = _db.streamGame(gameId!).listen((updated) {
      gameModel.value = updated;
      moveLocked.value = false;

      whiteTime.value = updated.whiteTime;
      blackTime.value = updated.blackTime;

      if (updated.fen != chess.fen) {
        chess.load(updated.fen);
        _updateState();
      }

      // Handle normal game over (or opponent left)
      if (updated.status == 'finished') {
        _handleGameOver(updated.winnerId);
      }
    });
  }

  // -------------------- UI INTERACTION --------------------

  void onSquareTap(String square) {
    if (selectedSquare.value == square) {
      selectedSquare.value = null;
      validMoves.clear();
      return;
    }

    if (selectedSquare.value != null) {
      if (makeMove(selectedSquare.value!, square)) {
        selectedSquare.value = null;
        validMoves.clear();
        return;
      }
    }

    final piece = chess.get(square);
    if (piece == null) return;

    if ((currentMode == GameMode.online || currentMode == GameMode.bot) && !_isMyTurn()) return;

    if (piece.color == chess.turn) {
      selectedSquare.value = square;
      final moves = chess.moves({'square': square, 'verbose': true}) as List;
      validMoves.value = moves.map((m) => m['to'] as String).toList();
    }
  }

  // -------------------- MOVE HANDLING --------------------

  bool makeMove(String from, String to) {
    if ((currentMode == GameMode.online || currentMode == GameMode.bot) && !_isMyTurn()) return false;

    if (currentMode == GameMode.online && moveLocked.value) return false;

    final move = chess.move({'from': from, 'to': to, 'promotion': 'q'});
    if (move == null) return false;

    if (currentMode == GameMode.online) {
      moveLocked.value = true;
      _uploadMoveOnline();
    }

    _updateState();

    print('currentMode ${currentMode} | ');
    if (currentMode == GameMode.bot) {
      Future.delayed(const Duration(milliseconds: 400), _botMove);
    }

    if (currentMode != GameMode.online && chess.game_over) {
      _handleGameOver(_determineWinnerId());
    }

    return true;
  }

  // -------------------- ONLINE MOVE UPLOAD --------------------

  void _uploadMoveOnline() {
    final model = gameModel.value!;
    final now = DateTime.now().millisecondsSinceEpoch;
    final elapsed = now - model.lastMoveAt;

    bool whiteJustMoved = chess.turn == chess_lib.Color.BLACK;

    int newWhite = model.whiteTime;
    int newBlack = model.blackTime;

    if (whiteJustMoved) {
      newWhite = max(0, newWhite - elapsed);
      whiteTime.value = newWhite;
    } else {
      newBlack = max(0, newBlack - elapsed);
      blackTime.value = newBlack;
    }

    final winnerId = chess.game_over ? _determineWinnerId() : null;

    _db.updateGame(
      model.copyWith(
        fen: chess.fen,
        status: chess.game_over ? 'finished' : 'active',
        winnerId: winnerId,
        lastMoveAt: now,
        currentTurn: chess.turn == chess_lib.Color.WHITE ? 'w' : 'b',
        whiteTime: newWhite,
        blackTime: newBlack,
      ),
    );

    if (chess.game_over) _handleGameOver(winnerId);
  }

  // -------------------- BOT --------------------

  void _botMove() {
    // If game already ended, handle it once
    if (chess.game_over) {
      _handleGameOver(_determineWinnerId());
      return;
    }

    // Bot should only move on its turn
    if (_isMyTurn()) return;

    final moves = chess.moves();

    // NO LEGAL MOVES = GAME OVER (stalemate or checkmate)
    if (moves.isEmpty) {
      _handleGameOver(_determineWinnerId());
      return;
    }

    // Make random bot move
    chess.move(moves[Random().nextInt(moves.length)]);
    _updateState();

    // Check again after move
    if (chess.game_over) {
      _handleGameOver(_determineWinnerId());
    }
  }

  // -------------------- HELPERS --------------------

  bool _isMyTurn() {
    return (chess.turn == chess_lib.Color.WHITE && myColor == 'w') || (chess.turn == chess_lib.Color.BLACK && myColor == 'b');
  }

  String? _determineWinnerId() {
    if (chess.in_checkmate) {
      // The side whose turn it is LOST
      if (chess.turn == chess_lib.Color.WHITE) {
        return myColor == 'b' ? _auth.appUser.value?.id : 'bot';
      } else {
        return myColor == 'w' ? _auth.appUser.value?.id : 'bot';
      }
    }

    // All of these are DRAWS
    if (chess.in_stalemate || chess.insufficient_material || chess.in_threefold_repetition || chess.in_draw) {
      return null;
    }

    return null;
  }

  void _updateState() {
    fen.value = chess.fen;
    currentTurn.value = chess.turn == chess_lib.Color.WHITE ? 'w' : 'b';

    final pgn = chess.pgn();
    if (pgn.isEmpty) {
      history.clear();
    } else {
      history.value = pgn.replaceAll(RegExp(r'\d+\.'), '').replaceAll('\n', ' ').trim().split(' ').where((e) => e.isNotEmpty).toList();
    }
    _calculateCapturedPieces();
  }

  void _calculateCapturedPieces() {
    Map<String, int> initialCounts = {
      'p': 8, 'n': 2, 'b': 2, 'r': 2, 'q': 1
    };
    Map<String, int> whiteCounts = {'p': 0, 'n': 0, 'b': 0, 'r': 0, 'q': 0};
    Map<String, int> blackCounts = {'p': 0, 'n': 0, 'b': 0, 'r': 0, 'q': 0};

    // Scan board
    for (var piece in chess.board) { // chess.board is List<Piece?>
       if (piece != null) {
          String typeKey = '';
           switch (piece.type) {
             case chess_lib.PieceType.PAWN: typeKey = 'p'; break;
             case chess_lib.PieceType.KNIGHT: typeKey = 'n'; break;
             case chess_lib.PieceType.BISHOP: typeKey = 'b'; break;
             case chess_lib.PieceType.ROOK: typeKey = 'r'; break;
             case chess_lib.PieceType.QUEEN: typeKey = 'q'; break;
             case chess_lib.PieceType.KING: typeKey = 'k'; break;
             default: typeKey = 'p'; 
          }

          if (piece.color == chess_lib.Color.WHITE) {
             whiteCounts[typeKey] = (whiteCounts[typeKey] ?? 0) + 1;
          } else {
             blackCounts[typeKey] = (blackCounts[typeKey] ?? 0) + 1;
          }
       }
    }

    List<String> wCaptured = [];
    List<String> bCaptured = [];

    // White's captured (What white has TAKEN from Black) -> Should be Initial Black - Current Black
    initialCounts.forEach((type, count) {
       int current = blackCounts[type] ?? 0;
       int captured = count - current;
       for (int i = 0; i < captured; i++) {
          wCaptured.add(type); 
       }
    });

    // Black's captured (What black has TAKEN from White) -> Should be Initial White - Current White
    initialCounts.forEach((type, count) {
       int current = whiteCounts[type] ?? 0;
       int captured = count - current;
       for (int i = 0; i < captured; i++) {
          bCaptured.add(type); 
       }
    });
    
    final validOrder = ['q', 'r', 'b', 'n', 'p'];
    wCaptured.sort((a, b) => validOrder.indexOf(a).compareTo(validOrder.indexOf(b)));
    bCaptured.sort((a, b) => validOrder.indexOf(a).compareTo(validOrder.indexOf(b)));

    whiteCaptured.value = wCaptured;
    blackCaptured.value = bCaptured;
  }

  // -------------------- GAME OVER --------------------

  void _handleGameOver(String? winnerId) {
    if (_gameOverHandled) return;
    _gameOverHandled = true;
    _timer?.cancel();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = _auth.appUser.value;
      if (user != null) {
        String result = 'draw';
        int points = 0;
        
        if (winnerId != null) {
          if (winnerId == user.id) {
            result = 'win';
            points = 10;
          } else {
            result = 'loss';
            points = -10;
          }
        }
        
        // Update Firebase stats
        _db.updateUserStats(user.id, points, result);
      }

      bool opponentLeft = gameModel.value?.leftBy != null && gameModel.value?.leftBy != myColor;
      bool iWon = user != null && winnerId == user.id;

      Get.defaultDialog(
        title: opponentLeft 
            ? "Opponent Left"
            : (winnerId == null ? 'Draw' : (iWon ? 'You Won!' : 'You Lost')),
        content: Text(
          opponentLeft
              ? "Your opponent has left the game. You win by default!"
              : (winnerId == null
                  ? 'Game ended in a draw.'
                  : (iWon ? 'Congratulations! +10 points' : 'Better luck next time.')),
        ),
        textConfirm: 'Home',
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.offAllNamed('/home');
        },
      );
    });
  }

  Future<void> exitGame() async {
    // Show confirmation dialog
    bool exit = await Get.defaultDialog<bool>(
      title: "Exit Game?",
      middleText: "Are you sure you want to leave the game? You will lose points.",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(result: true);
      },
      onCancel: () {
        Get.back(result: false);
      },
    ) ?? false;

    if (exit) {
      final user = _auth.appUser.value;

      // Handle online game cleanup before navigating away
      if (currentMode == GameMode.online && gameModel.value != null) {
        final game = gameModel.value!;
        String opponentId = myColor == 'w' ? game.blackPlayerId : game.whitePlayerId;
        
        // 1. Mark game as finished with opponent as winner
        await _db.updateGame(game.copyWith(
          status: 'finished',
          winnerId: opponentId,
          leftBy: myColor, 
          lastMoveAt: DateTime.now().millisecondsSinceEpoch,
        ));
        
        // 2. Penalize the leaver immediately
        if (user != null) {
          await _db.updateUserStats(user.id, -10, 'loss');
        }

        // Set flag to prevent double processing if stream still alive
        _gameOverHandled = true; 
      } else if (currentMode == GameMode.bot || currentMode == GameMode.local) {
        // For non-online games, maybe just count as a loss if mid-game?
        // User didn't specify, but let's keep it simple.
        if (user != null && !chess.game_over) {
           _db.updateUserStats(user.id, -5, 'loss');
        }
      }

      _timer?.cancel();
      gameSubscription?.cancel();
      Get.offAllNamed('/home');
    }
  }

  // -------------------- ACTIONS --------------------

  void undoMove() {
    if (currentMode == GameMode.online) return; // No undo in online ranked
    
    chess.undo(); // Undo opponent's move (or last move)
    if (currentMode == GameMode.bot) {
       chess.undo(); // Undo my move
    }
    _updateState();
  }

  Future<void> resignGame() async {
    bool confirm = await Get.defaultDialog<bool>(
      title: "Resign?",
      middleText: "Are you sure you want to resign the game?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    ) ?? false;

    if (confirm) {
      final user = _auth.appUser.value;
      if (currentMode == GameMode.online && gameModel.value != null) {
        final game = gameModel.value!;
        final winnerId = myColor == 'w' ? game.blackPlayerId : game.whitePlayerId;
        
        await _db.updateGame(game.copyWith(status: 'finished', winnerId: winnerId));
        if (user != null) {
          await _db.updateUserStats(user.id, -10, 'loss');
        }
        _gameOverHandled = true;
      } else if (user != null && !chess.game_over) {
         _db.updateUserStats(user.id, -5, 'loss');
      }
      
      _timer?.cancel();
      gameSubscription?.cancel();
      Get.offAllNamed('/home');
    }
  }

  void offerDraw() {
     if (currentMode != GameMode.online) return;
     Get.snackbar("Draw Offered", "Feature coming soon for online play");
  }

  void getHint() {
      final moves = chess.moves();
      if (moves.isNotEmpty) {
          final randomMove = moves[Random().nextInt(moves.length)]; // Placeholder for Stockfish
          Get.snackbar("Hint", "Try moving: ${randomMove.toString()}");
      }
  }

  @override
  void onClose() {
    _timer?.cancel();
    gameSubscription?.cancel();
    super.onClose();
  }
}
