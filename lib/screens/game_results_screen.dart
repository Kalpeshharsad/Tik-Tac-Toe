import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';
import 'package:kinetic_tictactoe/services/peer_service.dart';

class GameResultsScreen extends StatefulWidget {
  const GameResultsScreen({super.key});

  @override
  State<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends State<GameResultsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
  
    // If opponent resets the board, navigate back to game automatically.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<GameState>().addListener(_onGameStateChanged);
    });
  }

  void _onGameStateChanged() {
    if (!mounted || _navigating) return;
    final gs = context.read<GameState>();
    // Opponent sent a restart while we are on the Results screen
    if (!gs.gameOver && gs.isMultiplayer) {
      _navigating = true;
      context.go('/play?vsAI=false');
    }
  }

  @override
  void dispose() {
    try { context.read<GameState>().removeListener(_onGameStateChanged); } catch (_) {}
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDraw = gs.isDraw;
    final isWin = gs.isMyWin;
    final winner = gs.winner;
    
    // Determine colors/gradients
    final Color winColor;
    final Gradient winGradient;
    
    if (isDraw) {
      winColor = colorScheme.outline;
      winGradient = LinearGradient(colors: [colorScheme.outline, colorScheme.outlineVariant]);
    } else if (isWin) {
      final isXWin = winner == 'X';
      winColor = isXWin ? colorScheme.primary : colorScheme.secondary;
      winGradient = isXWin ? KGradients.primary(colorScheme) : KGradients.secondary(colorScheme);
    } else {
      // Loss color (e.g., error Red or dark Surface)
      winColor = colorScheme.error;
      winGradient = LinearGradient(colors: [colorScheme.error, colorScheme.errorContainer]);
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Radial celebration/loss background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    winColor.withValues(alpha: 0.15),
                    colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                // Mini app bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KINETIC',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          fontSize: 22,
                          color: colorScheme.primary,
                          letterSpacing: -1,
                        ),
                      ),
                      Icon(Icons.leaderboard_outlined,
                          color: colorScheme.onSurfaceVariant, size: 22),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Result Icon
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: ScaleTransition(
                            scale: _scaleAnim,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(KRadius.lg),
                                    gradient: winGradient,
                                    boxShadow: [
                                      BoxShadow(
                                        color: winColor.withValues(alpha: 0.3),
                                        blurRadius: 40,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius:
                                          BorderRadius.circular(KRadius.lg - 3),
                                    ),
                                    child: Icon(
                                      isDraw
                                          ? Icons.handshake_outlined
                                          : (isWin ? Icons.emoji_events_rounded : Icons.heart_broken_rounded),
                                      size: 56,
                                      color: winColor,
                                    ),
                                  ),
                                ),
                                if (isWin)
                                  Positioned(
                                    top: -8, right: -8,
                                    child: Transform.rotate(
                                      angle: 0.3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer,
                                          borderRadius: BorderRadius.circular(
                                              KRadius.full),
                                        ),
                                        child: Text(
                                          'MVP',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: colorScheme.onTertiaryContainer,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Headline
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Text(
                            isDraw ? 'Draw!' : (isWin ? 'Winner!' : 'You Lost!'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                              letterSpacing: -2,
                              height: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeTransition(
                          opacity: _fadeAnim,
                          child: Text(
                            isDraw
                                ? 'A perfectly balanced match!'
                                : (isWin 
                                    ? 'You dominated the grid in record time.'
                                    : 'Better luck next time! Practice makes perfect.'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Stats bento
                        Row(
                          children: [
                            Expanded(
                              child: _StatBox(
                                icon: Icons.timer_outlined,
                                iconColor: colorScheme.primary,
                                value: gs.formattedTime,
                                label: 'TIME TAKEN',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatBox(
                                icon: Icons.touch_app_outlined,
                                iconColor: colorScheme.secondary,
                                value: gs.moveCount.toString(),
                                label: 'TOTAL MOVES',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // XP card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(KRadius.lg),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.stars_rounded,
                                  color: colorScheme.tertiary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '+250 XP',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Rank Progress: Gold II',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: colorScheme.onSurfaceVariant),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Action buttons
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              if (_navigating) return;
                              _navigating = true;
                              if (gs.isMultiplayer) {
                                gs.resetBoard(broadcast: true);
                                context.go('/play?vsAI=false');
                              } else {
                                gs.resetBoard(broadcast: false);
                                context.go('/play');
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(KRadius.md),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.tertiary.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Text(
                                'Play Again',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: colorScheme.onTertiary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              if (gs.isMultiplayer) {
                                PeerService().endMatch();
                                gs.disableMultiplayer();
                              }
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
                              child: Text(
                                'Back to Lobby',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Match history row
                        _buildMatchHistory(gs, isDraw, colorScheme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHistory(GameState gs, bool isDraw, ColorScheme colorScheme) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'MATCH HISTORY',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                letterSpacing: 2,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // You (X)
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.surfaceContainerHigh,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Icon(Icons.person_rounded,
                          size: 20, color: colorScheme.primary),
                    ),
                    Positioned(
                      bottom: -2, right: -2,
                      child: Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: colorScheme.tertiary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface, width: 2),
                        ),
                        child: Icon(Icons.check_rounded,
                            size: 8, color: colorScheme.onTertiary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You (X)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      isDraw ? 'Draw' : (gs.winner == 'X' ? 'WINNER' : 'Runner Up'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: gs.winner == 'X'
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              'VS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: -0.5,
              ),
            ),
            // Bot
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Bot_Aura (O)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      isDraw ? 'Draw' : (gs.winner == 'O' ? 'WINNER' : 'Runner Up'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.surfaceContainerHigh,
                    border: Border.all(
                      color: colorScheme.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: Icon(Icons.smart_toy_rounded,
                      size: 20, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KRadius.lg),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
