import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';

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
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final isDraw = gs.isDraw;
    final winner = gs.winner;
    final isXWin = winner == 'X';

    final winColor = isXWin ? KColors.primary : KColors.secondary;
    final winGradient = isXWin ? KGradients.primary : KGradients.secondary;

    return Scaffold(
      backgroundColor: KColors.surface,
      body: Stack(
        children: [
          // Radial celebration background
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: isDraw
                      ? [
                          KColors.outline.withOpacity(0.15),
                          KColors.surface,
                        ]
                      : [
                          winColor.withOpacity(0.15),
                          KColors.surface,
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
                          color: KColors.primary,
                          letterSpacing: -1,
                        ),
                      ),
                      const Icon(Icons.leaderboard_outlined,
                          color: KColors.onSurfaceVariant, size: 22),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // Trophy icon
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
                                        color: winColor.withOpacity(0.3),
                                        blurRadius: 40,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(3),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: KColors.surface,
                                      borderRadius:
                                          BorderRadius.circular(KRadius.lg - 3),
                                    ),
                                    child: Icon(
                                      isDraw
                                          ? Icons.handshake_outlined
                                          : Icons.emoji_events_rounded,
                                      size: 56,
                                      color: winColor,
                                    ),
                                  ),
                                ),
                                if (!isDraw)
                                  Positioned(
                                    top: -8, right: -8,
                                    child: Transform.rotate(
                                      angle: 0.3,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: KColors.tertiaryContainer,
                                          borderRadius: BorderRadius.circular(
                                              KRadius.full),
                                        ),
                                        child: Text(
                                          'MVP',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: KColors.onTertiaryContainer,
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
                            isDraw ? 'Draw!' : 'Winner!',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 60,
                              fontWeight: FontWeight.w900,
                              color: KColors.onSurface,
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
                                : 'You dominated the grid in record time.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              color: KColors.onSurfaceVariant,
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
                                iconColor: KColors.primary,
                                value: gs.formattedTime,
                                label: 'TIME TAKEN',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatBox(
                                icon: Icons.touch_app_outlined,
                                iconColor: KColors.secondary,
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
                            color: KColors.surfaceContainerHigh.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(KRadius.lg),
                            border: Border.all(
                              color: KColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(
                                  color: KColors.surfaceContainerHighest,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.stars_rounded,
                                  color: KColors.tertiary,
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
                                        color: KColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      'Rank Progress: Gold II',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: KColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: KColors.onSurfaceVariant),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        // Action buttons
                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              gs.resetBoard();
                              context.go('/play');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: KColors.tertiary,
                                borderRadius: BorderRadius.circular(KRadius.md),
                                boxShadow: [
                                  BoxShadow(
                                    color: KColors.tertiary.withOpacity(0.2),
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
                                  color: KColors.onTertiary,
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
                              gs.resetAll();
                              context.go('/');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: KColors.surfaceBright,
                                borderRadius: BorderRadius.circular(KRadius.md),
                                border: Border.all(
                                  color: KColors.outlineVariant.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Back to Lobby',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: KColors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Match history row
                        _buildMatchHistory(gs, isDraw),
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

  Widget _buildMatchHistory(GameState gs, bool isDraw) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              'MATCH HISTORY',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: KColors.onSurfaceVariant.withOpacity(0.6),
                letterSpacing: 2,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 12),
                height: 1,
                color: KColors.outlineVariant.withOpacity(0.3),
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
                        color: KColors.surfaceContainerHigh,
                        border: Border.all(
                          color: KColors.primary,
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 20, color: KColors.primary),
                    ),
                    Positioned(
                      bottom: -2, right: -2,
                      child: Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: KColors.tertiaryFixed,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: KColors.surface, width: 2),
                        ),
                        child: const Icon(Icons.check_rounded,
                            size: 8, color: KColors.onTertiary),
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
                        color: KColors.onSurface,
                      ),
                    ),
                    Text(
                      isDraw ? 'Draw' : (gs.winner == 'X' ? 'WINNER' : 'Runner Up'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: gs.winner == 'X'
                            ? KColors.primary
                            : KColors.onSurfaceVariant,
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
                color: KColors.onSurfaceVariant,
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
                        color: KColors.onSurface,
                      ),
                    ),
                    Text(
                      isDraw ? 'Draw' : (gs.winner == 'O' ? 'WINNER' : 'Runner Up'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: KColors.onSurfaceVariant,
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
                    color: KColors.surfaceContainerHigh,
                    border: Border.all(
                      color: KColors.outlineVariant,
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.smart_toy_rounded,
                      size: 20, color: KColors.onSurfaceVariant),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KRadius.lg),
        border: Border.all(
          color: KColors.outlineVariant.withOpacity(0.1),
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
              color: KColors.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: KColors.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
