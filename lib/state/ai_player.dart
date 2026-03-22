/// Minimax-based AI for Tic-Tac-Toe.
/// Returns the best move index for the given board and player.
class AiPlayer {
  final String aiMark;
  final String humanMark;

  const AiPlayer({this.aiMark = 'O', this.humanMark = 'X'});

  static const List<List<int>> _winLines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  int getBestMove(List<String?> board) {
    int bestScore = -1000;
    int bestMove = -1;
    for (int i = 0; i < 9; i++) {
      if (board[i] == null) {
        final newBoard = List<String?>.from(board);
        newBoard[i] = aiMark;
        final score = _minimax(newBoard, false, 0);
        if (score > bestScore) {
          bestScore = score;
          bestMove = i;
        }
      }
    }
    return bestMove;
  }

  int _minimax(List<String?> board, bool isMaximizing, int depth) {
    final result = _evaluate(board);
    if (result != null) return result - depth;
    if (!board.contains(null)) return 0;

    if (isMaximizing) {
      int best = -1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == null) {
          final newBoard = List<String?>.from(board);
          newBoard[i] = aiMark;
          best = best > _minimax(newBoard, false, depth + 1)
              ? best
              : _minimax(newBoard, false, depth + 1);
        }
      }
      return best;
    } else {
      int best = 1000;
      for (int i = 0; i < 9; i++) {
        if (board[i] == null) {
          final newBoard = List<String?>.from(board);
          newBoard[i] = humanMark;
          best = best < _minimax(newBoard, true, depth + 1)
              ? best
              : _minimax(newBoard, true, depth + 1);
        }
      }
      return best;
    }
  }

  int? _evaluate(List<String?> board) {
    for (final line in _winLines) {
      final a = board[line[0]];
      final b = board[line[1]];
      final c = board[line[2]];
      if (a != null && a == b && b == c) {
        return a == aiMark ? 10 : -10;
      }
    }
    return null;
  }
}
