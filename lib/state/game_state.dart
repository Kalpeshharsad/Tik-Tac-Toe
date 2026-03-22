import 'package:flutter/material.dart';

/// Tracks whose turn it is, board state, scores, win detection.
class GameState extends ChangeNotifier {
  static const int boardSize = 9;

  List<String?> _board = List.filled(boardSize, null);
  String _currentPlayer = 'X';
  String? _winner; // 'X', 'O', or 'DRAW'
  List<int>? _winningLine;
  int _xScore = 0;
  int _oScore = 0;
  int _drawCount = 0;
  int _moveCount = 0;
  bool _gameOver = false;

  // Timer
  int _elapsedSeconds = 0;

  // ── Getters ──────────────────────────────────────────────────────────────
  List<String?> get board => List.unmodifiable(_board);
  String get currentPlayer => _currentPlayer;
  String? get winner => _winner;
  List<int>? get winningLine => _winningLine;
  int get xScore => _xScore;
  int get oScore => _oScore;
  int get drawCount => _drawCount;
  int get moveCount => _moveCount;
  bool get gameOver => _gameOver;
  int get elapsedSeconds => _elapsedSeconds;
  bool get isDraw => _winner == 'DRAW';

  // ── Win conditions ────────────────────────────────────────────────────────
  static const List<List<int>> _winLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
    [0, 4, 8], [2, 4, 6],             // diagonals
  ];

  // ── Actions ───────────────────────────────────────────────────────────────
  bool makeMove(int index) {
    if (_board[index] != null || _gameOver) return false;
    _board[index] = _currentPlayer;
    _moveCount++;
    _checkResult();
    if (!_gameOver) {
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
    }
    notifyListeners();
    return true;
  }

  void _checkResult() {
    for (final line in _winLines) {
      final a = _board[line[0]];
      final b = _board[line[1]];
      final c = _board[line[2]];
      if (a != null && a == b && b == c) {
        _winner = a;
        _winningLine = line;
        _gameOver = true;
        if (a == 'X') _xScore++;
        if (a == 'O') _oScore++;
        return;
      }
    }
    if (!_board.contains(null)) {
      _winner = 'DRAW';
      _gameOver = true;
      _drawCount++;
    }
  }

  void tickTimer() {
    if (_gameOver) return;
    _elapsedSeconds++;
    notifyListeners();
  }

  void resetBoard() {
    _board = List.filled(boardSize, null);
    _currentPlayer = 'X';
    _winner = null;
    _winningLine = null;
    _gameOver = false;
    _moveCount = 0;
    _elapsedSeconds = 0;
    notifyListeners();
  }

  void resetAll() {
    _xScore = 0;
    _oScore = 0;
    _drawCount = 0;
    resetBoard();
  }

  String get formattedTime {
    final m = _elapsedSeconds ~/ 60;
    final s = _elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
