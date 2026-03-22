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
import 'package:kinetic_tictactoe/state/settings_state.dart';
import 'package:kinetic_tictactoe/utils/sound_manager.dart';
import 'package:kinetic_tictactoe/services/nearby_service.dart';

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
      _setupMultiplayer();
    });
  }

  void _setupMultiplayer() {
    final gs = context.read<GameState>();
    if (!gs.isMultiplayer) return;

    final nearby = NearbyService();
    
    // Send local moves
    gs.onMoveMade = (index) {
      nearby.sendMove(index);
    };

    nearby.onDataReceived = (data) {
      if (data['type'] == 'move') {
        final index = data['index'] as int;
        final settings = context.read<SettingsState>();
        gs.makeMove(index, hapticsEnabled: settings.hapticsEnabled, isRemote: true);
        if (settings.soundFxEnabled) SoundManager.instance.playMove();
        if (gs.gameOver) {
          _onGameOver(gs, settings);
        }
      } else if (data['type'] == 'emoji') {
        _showRemoteEmoji(data['emoji'] as String);
      }
    };

    nearby.onDisconnected = (id) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opponent disconnected')),
        );
        context.go('/lobby');
      }
    };
  }

  void _showRemoteEmoji(String emoji) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opponent says: $emoji'), duration: const Duration(seconds: 1)),
    );
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
    final settings = context.read<SettingsState>();
    if (gs.gameOver) return;

    // Block input if not my turn in multiplayer
    if (gs.isMultiplayer && !gs.isMyTurn) return;
    
    if (widget.vsAI && gs.currentPlayer == 'O') return;

    final moved = gs.makeMove(index, hapticsEnabled: settings.hapticsEnabled);
    if (moved) {
      if (settings.soundFxEnabled) SoundManager.instance.playMove();
      if (gs.gameOver) {
        _onGameOver(gs, settings);
        return;
      }
    }

    // AI turn
    if (moved && widget.vsAI && !gs.gameOver) {
      _aiTimer = Timer(const Duration(milliseconds: 500), () {
        final aiMove = _ai.getBestMove(List<String?>.from(gs.board));
        if (aiMove >= 0) {
          final aiMoved = gs.makeMove(aiMove, hapticsEnabled: settings.hapticsEnabled);
          if (aiMoved) {
            if (settings.soundFxEnabled) SoundManager.instance.playMove();
            if (gs.gameOver) _onGameOver(gs, settings);
          }
        }
      });
    }
  }

  void _onGameOver(GameState gs, SettingsState settings) async {
    if (settings.soundFxEnabled) {
      if (gs.isDraw) {
        SoundManager.instance.playDraw();
      } else {
        SoundManager.instance.playWin();
      }
    }
    await _winCtrl.forward(from: 0);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      context.go('/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const KineticAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: Column(
          children: [
            _buildScoreboard(gs, colorScheme),
            const SizedBox(height: 16),
            _buildControls(gs, colorScheme),
            const SizedBox(height: 16),
            _buildGrid(gs, colorScheme),
            const SizedBox(height: 20),
            _buildActionButtons(context, gs, colorScheme),
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

  Widget _buildScoreboard(GameState gs, ColorScheme colorScheme) {
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
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(KRadius.lg),
              border: isXTurn
                  ? Border.all(color: colorScheme.primary.withValues(alpha: 0.3), width: 1.5)
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0, top: 0, bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: isXTurn ? 0.8 : 0.3),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(KRadius.lg),
                        bottomLeft: Radius.circular(KRadius.lg),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0, right: 0,
                  child: _PulsingStatusDot(color: colorScheme.tertiary),
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
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShaderMask(
                            shaderCallback: (b) => KGradients.primary(colorScheme).createShader(b),
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
                              color: colorScheme.onSurface,
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
        // Player 2 (O)
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isOTurn
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(KRadius.lg),
              border: isOTurn
                  ? Border.all(
                      color: colorScheme.secondary.withValues(alpha: 0.25), width: 1.5)
                  : null,
              boxShadow: isOTurn
                  ? [
                      BoxShadow(
                        color: colorScheme.secondary.withValues(alpha: 0.08),
                        blurRadius: 20,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 0, top: 0, bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: isOTurn ? colorScheme.secondary : colorScheme.secondary.withValues(alpha: 0.3),
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
                        color: isOTurn ? colorScheme.secondary : colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShaderMask(
                          shaderCallback: (b) => KGradients.secondary(colorScheme).createShader(b),
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
                            color: colorScheme.onSurface,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    if (isOTurn) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.66,
                          minHeight: 4,
                          backgroundColor: colorScheme.surfaceContainer,
                          valueColor:
                              AlwaysStoppedAnimation(colorScheme.secondary),
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

  Widget _buildControls(GameState gs, ColorScheme colorScheme) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            gs.resetBoard();
            _winCtrl.reset();
            _startTimer();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceBright.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.undo_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ELAPSED',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              gs.formattedTime,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(KRadius.full),
          ),
          child: Text(
            gs.gameOver
                ? (gs.isDraw ? 'Draw!' : '${gs.winner} Wins!')
                : '${gs.currentPlayer == 'X' ? 'X' : 'O'}\'s Turn',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(GameState gs, ColorScheme colorScheme) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
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

  Widget _buildActionButtons(BuildContext context, GameState gs, ColorScheme colorScheme) {
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
                color: colorScheme.tertiary,
                borderRadius: BorderRadius.circular(KRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.tertiary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded,
                      color: colorScheme.onTertiary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'RESTART GAME',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onTertiary,
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
              gs.disableMultiplayer();
              gs.resetAll();
              context.go('/');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceBright,
                borderRadius: BorderRadius.circular(KRadius.md),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
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
                      color: colorScheme.onSurface,
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
