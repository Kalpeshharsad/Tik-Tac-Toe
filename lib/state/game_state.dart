import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kinetic_tictactoe/services/peer_service.dart';

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
  
  // Multiplayer
  bool _isMultiplayer = false;
  String? _mySign; // 'X' or 'O'
  void Function(int index)? onMoveMade; // Callback to send move over P2P

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
  bool get isMultiplayer => _isMultiplayer;
  String? get mySign => _mySign;
  bool get isMyTurn => !_isMultiplayer || (_currentPlayer == _mySign);
  bool get isMyWin => _winner != null && _winner != 'DRAW' && (_isMultiplayer ? _winner == _mySign : _winner == 'X');
  bool get isMyLoss => _winner != null && _winner != 'DRAW' && (_isMultiplayer ? _winner != _mySign : _winner == 'O');

  // ── Win conditions ────────────────────────────────────────────────────────
  static const List<List<int>> _winLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // cols
    [0, 4, 8], [2, 4, 6],             // diagonals
  ];

  // ── Actions ───────────────────────────────────────────────────────────────
  bool makeMove(int index, {bool hapticsEnabled = true, bool isRemote = false}) {
    if (_board[index] != null || _gameOver) return false;
    
    // In multiplayer, only allow local player to move on their turn
    if (_isMultiplayer && !isRemote && _currentPlayer != _mySign) return false;

    _board[index] = _currentPlayer;
    _moveCount++;
    if (hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
    _checkResult();
    
    // Notify multiplayer service if this was a local move
    if (_isMultiplayer && !isRemote) {
      PeerService().sendMessage({'type': 'move', 'index': index});
    }

    if (!_gameOver) {
      _currentPlayer = _currentPlayer == 'X' ? 'O' : 'X';
    }
    notifyListeners();
    return true;
  }

  void setupMultiplayer(String mySign) {
    _isMultiplayer = true;
    _mySign = mySign;
    _setupPeerListeners();
    resetAll();
  }

  void _setupPeerListeners() {
    final peerService = PeerService();
    peerService.onDataReceived = (data) {
      if (data['type'] == 'move') {
        final index = data['index'] as int;
        // In GameState we can't easily access SettingsState directly without passing it,
        // but for basic move sync we can default haptics to true or false.
        makeMove(index, isRemote: true);
        
        // Note: Sound normally playing in UI, but if GameState is the source of truth,
        // we might want a way to notify UI to play sound.
      }
    };
  }

  void disableMultiplayer() {
    _isMultiplayer = false;
    _mySign = null;
    PeerService().onDataReceived = null;
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
