import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';
import 'package:kinetic_tictactoe/widgets/kinetic_app_bar.dart';
import 'package:kinetic_tictactoe/widgets/bottom_nav_bar.dart';
import 'package:kinetic_tictactoe/widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: KineticAppBar(
              onLeaderboardTap: () => context.push('/leaderboard'),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 140),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeroSection(context),
                _buildStatsBento(context, gameState),
                _buildMenuButtons(context),
                _buildDailyChallenges(context),
                _buildElitePlayers(context),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: KineticBottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) context.go('/play');
          if (i == 2) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Stack(
        children: [
          // Ambient glows
          Positioned(
            top: -48, right: -48,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KColors.primary.withValues(alpha: 0.08),
              ),
              child: const SizedBox(),
            ),
          ),
          Positioned(
            bottom: -48, left: -48,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KColors.secondary.withValues(alpha: 0.08),
              ),
              child: const SizedBox(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXPERIENCE KINETIC PRECISION',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: KColors.primary,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tension.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: KColors.onSurface,
                  height: 1.0,
                  letterSpacing: -1.5,
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => KGradients.primary.createShader(bounds),
                child: Text(
                  'Strategy.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -1.5,
                  ),
                ),
              ),
              Text(
                'Victory.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: KColors.onSurface,
                  height: 1.0,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Redefining the classic 3×3 stage with high-energy visuals and competitive play.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: KColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBento(BuildContext context, GameState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Total Wins',
              value: state.xScore.toString().padLeft(3, '0'),
              valueColor: KColors.onSurface,
              badge: SizedBox(
                height: 24,
                child: Icon(
                  Icons.military_tech_rounded,
                  color: KColors.primary.withValues(alpha: 0.2),
                  size: 28,
                ),
              ),
              footer: Row(
                children: [
                  _PulsingDot(),
                  const SizedBox(width: 6),
                  Text(
                    'Top 5% Globally',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: KColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              label: 'Recent Streak',
              value: state.oScore.toString().padLeft(2, '0'),
              valueColor: KColors.secondary,
              footer: Row(
                children: [
                  for (final mark in ['X', 'O', 'X'])
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: mark == 'X' ? KColors.primary : KColors.secondary,
                        border: Border.all(
                          color: KColors.surfaceContainerLow,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          mark,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: mark == 'X'
                                ? KColors.onPrimary
                                : KColors.onSecondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          // Play Now
          GestureDetector(
            onTap: () => context.go('/play'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                color: KColors.tertiary,
                borderRadius: BorderRadius.circular(KRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Play Now',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: KColors.onTertiary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Single Player vs Kinetic AI',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: KColors.onTertiary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: KColors.onTertiary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_outlined,
                      color: KColors.onTertiary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Multiplayer Lobby
          GestureDetector(
            onTap: () => context.go('/lobby'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
              decoration: BoxDecoration(
                color: KColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KRadius.md),
                border: Border.all(
                  color: KColors.outlineVariant.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Multiplayer Lobby',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: KColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Challenge players worldwide',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: KColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: KColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.public_rounded,
                      color: KColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallenges(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: KColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(KRadius.lg),
          border: Border.all(
            color: KColors.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Challenges',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: KColors.onSurface,
                      ),
                    ),
                    Text('Expires in 14h 22m',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: KColors.onSurfaceVariant,
                        )),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: KColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(KRadius.full),
                  ),
                  child: Text(
                    'XP BOOST ×2',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: KColors.secondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _ChallengeRow(
              icon: Icons.grid_3x3_rounded,
              iconColor: KColors.primary,
              label: "Win 3 games with 'X'",
              current: 2,
              total: 3,
              gradient: KGradients.primary,
            ),
            const SizedBox(height: 16),
            _ChallengeRow(
              icon: Icons.history_rounded,
              iconColor: KColors.secondary,
              label: 'Complete match in 1 min',
              current: 0,
              total: 1,
              gradient: KGradients.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElitePlayers(BuildContext context) {
    final players = [
      {'name': 'NeonRacer', 'rank': '#1 WORLD', 'top': true},
      {'name': 'VoidWalker', 'rank': '#2 WORLD', 'top': false},
      {'name': 'Kinetic01', 'rank': '#3 WORLD', 'top': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Text(
            'Elite Players',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: KColors.onSurface,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            itemCount: players.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final p = players[i];
              final isTop = p['top'] == true;
              return Container(
                width: 130,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(KRadius.lg),
                  border: isTop
                      ? Border(
                          bottom: BorderSide(
                            color: KColors.primary,
                            width: 2,
                          ),
                        )
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: KColors.surfaceBright,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isTop
                              ? KColors.primary.withValues(alpha: 0.5)
                              : KColors.outlineVariant.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: isTop ? KColors.primary : KColors.onSurfaceVariant,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      p['name'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: KColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p['rank'] as String,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isTop
                            ? KColors.primary
                            : KColors.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        width: 8, height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: KColors.tertiaryFixed
              .withValues(alpha: 0.5 + 0.5 * _ctrl.value),
          boxShadow: [
            BoxShadow(
              color: KColors.tertiaryFixed.withValues(alpha: 0.3 * _ctrl.value),
              blurRadius: 6,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final int current;
  final int total;
  final Gradient gradient;

  const _ChallengeRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.current,
    required this.total,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: KColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KRadius.md),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: KColors.onSurface,
                    ),
                  ),
                  Text(
                    '$current/$total',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: KColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: KColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(iconColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
