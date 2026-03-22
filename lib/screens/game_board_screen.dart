import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';
import 'package:kinetic_tictactoe/state/ai_player.dart';
import 'package:kinetic_tictactoe/widgets/kinetic_app_bar.dart';
import 'package:kinetic_tictactoe/widgets/bottom_nav_bar.dart';
import 'package:kinetic_tictactoe/widgets/game_tile.dart';
import 'package:kinetic_tictactoe/widgets/win_line_painter.dart';

class GameBoardScreen extends StatefulWidget {
  final bool vsAI;
  const GameBoardScreen({super.key, this.vsAI = true});

  @override
  State<GameBoardScreen> createState() => _GameBoardScreenState();
}

class _GameBoardScreenState extends State<GameBoardScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Timer? _aiTimer;

  // Win line animation
  late AnimationController _winCtrl;
  late Animation<double> _winProgress;

  final AiPlayer _ai = const AiPlayer(aiMark: 'O', humanMark: 'X');

  @override
  void initState() {
    super.initState();
    _winCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _winProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _winCtrl, curve: Curves.easeOut),
    );

    // Start timer
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final gs = context.read<GameState>();
      if (!gs.gameOver) gs.tickTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _aiTimer?.cancel();
    _winCtrl.dispose();
    super.dispose();
  }

  void _onTileTap(int index) {
    final gs = context.read<GameState>();
    if (gs.gameOver) return;
    if (widget.vsAI && gs.currentPlayer == 'O') return;

    final moved = gs.makeMove(index);
    if (moved && gs.gameOver) {
      _onGameOver(gs);
      return;
    }

    // AI turn
    if (moved && widget.vsAI && !gs.gameOver) {
      _aiTimer = Timer(const Duration(milliseconds: 500), () {
        final aiMove = _ai.getBestMove(List<String?>.from(gs.board));
        if (aiMove >= 0) {
          gs.makeMove(aiMove);
          if (gs.gameOver) _onGameOver(gs);
        }
      });
    }
  }

  void _onGameOver(GameState gs) async {
    await _winCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      context.go('/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();

    return Scaffold(
      backgroundColor: KColors.surface,
      appBar: const KineticAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          children: [
            _buildScoreboard(gs),
            const SizedBox(height: 16),
            _buildControls(gs),
            const SizedBox(height: 16),
            _buildGrid(gs),
            const SizedBox(height: 20),
            _buildActionButtons(context, gs),
          ],
        ),
      ),
      bottomNavigationBar: KineticBottomNavBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/lobby');
        },
      ),
    );
  }

  Widget _buildScoreboard(GameState gs) {
    final isXTurn = gs.currentPlayer == 'X' && !gs.gameOver;
    final isOTurn = gs.currentPlayer == 'O' && !gs.gameOver;

    return Row(
      children: [
        // Player 1 (X)
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: KColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(KRadius.lg),
              border: isXTurn
                  ? Border.all(color: KColors.primary.withValues(alpha: 0.3), width: 1.5)
                  : null,
            ),
            child: Stack(
              children: [
                // Left accent bar
                Positioned(
                  left: 0, top: 0, bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: KColors.primary.withValues(alpha: isXTurn ? 0.8 : 0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(KRadius.lg),
                        bottomLeft: Radius.circular(KRadius.lg),
                      ),
                    ),
                  ),
                ),
                // Online indicator
                Positioned(
                  top: 0, right: 0,
                  child: _PulsingStatusDot(color: KColors.tertiaryFixed),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLAYER 1',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: KColors.onSurfaceVariant,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => KGradients.primary.createShader(b),
                            child: Text(
                              'X',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            gs.xScore.toString().padLeft(2, '0'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 44,
                              fontWeight: FontWeight.w700,
                              color: KColors.onSurface,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Player 2 (O) — active state
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isOTurn
                  ? KColors.surfaceContainerHigh
                  : KColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(KRadius.lg),
              border: isOTurn
                  ? Border.all(
                      color: KColors.secondary.withValues(alpha: 0.25), width: 1.5)
                  : null,
              boxShadow: isOTurn
                  ? [
                      BoxShadow(
                        color: KColors.secondary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                // Right accent bar
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: isOTurn ? KColors.secondary : KColors.secondary.withValues(alpha: 0.3),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(KRadius.lg),
                        bottomRight: Radius.circular(KRadius.lg),
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOTurn ? 'YOUR TURN' : (widget.vsAI ? 'KINETIC AI' : 'PLAYER 2'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isOTurn ? KColors.secondary : KColors.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => KGradients.secondary.createShader(b),
                          child: Text(
                            'O',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          gs.oScore.toString().padLeft(2, '0'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                            color: KColors.onSurface,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    if (isOTurn) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: const LinearProgressIndicator(
                          value: 0.66,
                          minHeight: 4,
                          backgroundColor: KColors.surfaceContainer,
                          valueColor:
                              AlwaysStoppedAnimation(KColors.secondary),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls(GameState gs) {
    return Row(
      children: [
        // Undo + Timer
        GestureDetector(
          onTap: () {
            gs.resetBoard();
            _winCtrl.reset();
            _startTimer();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: KColors.surfaceBright.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: KColors.outlineVariant.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.undo_rounded,
              color: KColors.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REMAINING',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: KColors.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              gs.formattedTime,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: KColors.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: KColors.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(KRadius.full),
          ),
          child: Text(
            gs.gameOver
                ? (gs.isDraw ? 'Draw!' : '${gs.winner} Wins!')
                : '${gs.currentPlayer == 'X' ? 'X' : 'O'}\'s Turn',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: KColors.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(GameState gs) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(KRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _winProgress,
          builder: (context, _) {
            return Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final isWinning =
                        gs.winningLine?.contains(index) ?? false;
                    return GameTile(
                      value: gs.board[index],
                      onTap: () => _onTileTap(index),
                      isWinning: isWinning,
                    );
                  },
                ),
                if (gs.winningLine != null)
                  IgnorePointer(
                    child: CustomPaint(
                      painter: WinLinePainter(
                        winningLine: gs.winningLine,
                        progress: _winProgress.value,
                        winner: gs.winner ?? 'X',
                      ),
                      size: Size.infinite,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, GameState gs) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              gs.resetBoard();
              _winCtrl.reset();
              _startTimer();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: KColors.tertiary,
                borderRadius: BorderRadius.circular(KRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: KColors.tertiary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.refresh_rounded,
                      color: KColors.onTertiary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'RESTART GAME',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: KColors.onTertiary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              gs.resetAll();
              context.go('/');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: KColors.surfaceBright,
                borderRadius: BorderRadius.circular(KRadius.md),
                border: Border.all(
                  color: KColors.outlineVariant.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded,
                      color: KColors.error, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'QUIT MATCH',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: KColors.onSurface,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PulsingStatusDot extends StatefulWidget {
  final Color color;
  const _PulsingStatusDot({required this.color});

  @override
  State<_PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<_PulsingStatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.5 * _ctrl.value),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
