import 'package:flutter/material.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';

/// Paints an animated glowing line through the 3 winning tiles.
class WinLinePainter extends CustomPainter {
  final List<int>? winningLine;
  final double progress; // 0.0 → 1.0
  final String winner; // 'X' or 'O'

  const WinLinePainter({
    required this.winningLine,
    required this.progress,
    required this.winner,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (winningLine == null || progress == 0) return;

    // Calculate tile size (3x3 grid with 12px gaps, 16px padding)
    final gap = 12.0;
    final padding = 16.0;
    final tileW = (size.width - padding * 2 - gap * 2) / 3;
    final tileH = (size.height - padding * 2 - gap * 2) / 3;

    Offset center(int index) {
      final col = index % 3;
      final row = index ~/ 3;
      final x = padding + col * (tileW + gap) + tileW / 2;
      final y = padding + row * (tileH + gap) + tileH / 2;
      return Offset(x, y);
    }

    final start = center(winningLine![0]);
    final end = center(winningLine![2]);
    final current = Offset.lerp(start, end, progress)!;

    final color = winner == 'X' ? KColors.primary : KColors.secondary;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawLine(start, current, paint);

    // Solid core
    final corePaint = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, current, corePaint);
  }

  @override
  bool shouldRepaint(WinLinePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.winningLine != winningLine;
}
