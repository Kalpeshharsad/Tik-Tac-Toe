import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/widgets/bottom_nav_bar.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.surface,
      bottomNavigationBar: KineticBottomNavBar(
        currentIndex: 2, // Needs to be updated in the widget if we want to add more icons
        onTap: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/play');
          if (i == 2) context.go('/settings');
        },
      ),
      body: Stack(
        children: [
          // Ambient backgrounds
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(bottom: 100, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: KColors.secondary.withValues(alpha: 0.05)))),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.grid_view_rounded, color: KColors.primary, size: 24),
                          const SizedBox(width: 12),
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
                        ],
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: KColors.primary.withValues(alpha: 0.2), width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          'https://api.dicebear.com/7.x/avataaars/png?seed=Alex',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 160),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'Rankings',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: KColors.onSurface,
                            letterSpacing: -1,
                          ),
                        ),
                        Text(
                          'SEASON 12: NEON CIRCUIT',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: KColors.onSurfaceVariant,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Podium Section
                        const _RankPodium(),

                        const SizedBox(height: 40),

                        // Global Elite List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GLOBAL ELITE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: KColors.onSurfaceVariant.withValues(alpha: 0.6),
                                letterSpacing: 2.5,
                              ),
                            ),
                            Text(
                              'XP / WIN RATIO',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: KColors.primary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _RankList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Rank Card
          const Positioned(
            bottom: 110,
            left: 24,
            right: 24,
            child: _StickyUserRank(),
          ),
        ],
      ),
    );
  }
}

class _RankPodium extends StatelessWidget {
  const _RankPodium();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Rank 2
          Expanded(
            child: _PodiumColumn(
              rank: 2,
              name: 'VoidWalker',
              wins: '842',
              avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Void',
              height: 140,
            ),
          ),
          const SizedBox(width: 8),
          // Rank 1
          Expanded(
            child: _PodiumColumn(
              rank: 1,
              name: 'NeonRacer',
              wins: '1,204',
              avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Neon',
              height: 180,
              isFirst: true,
            ),
          ),
          const SizedBox(width: 8),
          // Rank 3
          Expanded(
            child: _PodiumColumn(
              rank: 3,
              name: 'CyberLuna',
              wins: '756',
              avatar: 'https://api.dicebear.com/7.x/avataaars/png?seed=Luna',
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final int rank;
  final String name;
  final String wins;
  final String avatar;
  final double height;
  final bool isFirst;

  const _PodiumColumn({
    required this.rank,
    required this.name,
    required this.wins,
    required this.avatar,
    required this.height,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Avatar
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isFirst ? 80 : 64,
              height: isFirst ? 80 : 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFirst ? KColors.primary : KColors.primary.withValues(alpha: 0.3),
                  width: isFirst ? 3 : 2,
                ),
                boxShadow: isFirst
                    ? [
                        BoxShadow(
                          color: KColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle),
                clipBehavior: Clip.antiAlias,
                child: Image.network(avatar, fit: BoxFit.cover),
              ),
            ),
            if (isFirst)
              Positioned(
                bottom: -10,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: KColors.primary,
                      borderRadius: BorderRadius.circular(KRadius.full),
                      boxShadow: [
                        BoxShadow(
                          color: KColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: Text(
                      'KING',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: KColors.onPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: -8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: KColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(KRadius.full),
                      border: Border.all(color: KColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      '#$rank',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: KColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: isFirst ? 14 : 12,
            fontWeight: isFirst ? FontWeight.w900 : FontWeight.w700,
            color: isFirst ? KColors.primary : KColors.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$wins WINS',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: isFirst ? KColors.tertiaryFixed : KColors.primary.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        // Podium block
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: isFirst
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      KColors.primary.withValues(alpha: 0.2),
                      KColors.primary.withValues(alpha: 0.02),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      KColors.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(KRadius.lg)),
            border: Border(
              top: BorderSide(
                color: KColors.primary.withValues(alpha: isFirst ? 0.4 : 0.1),
                width: isFirst ? 2 : 1,
              ),
            ),
          ),
          child: Icon(
            rank == 1
                ? Icons.workspace_premium_rounded
                : (rank == 2 ? Icons.shield_rounded : Icons.star_rounded),
            color: KColors.primary.withValues(alpha: isFirst ? 0.4 : 0.2),
            size: isFirst ? 40 : 24,
          ),
        ),
      ],
    );
  }
}

class _RankList extends StatelessWidget {
  const _RankList();

  @override
  Widget build(BuildContext context) {
    final players = [
      {'rank': '04', 'name': 'GlitchMatrix', 'badge': 'ELITE', 'xp': '18.4K', 'wr': '78%'},
      {'rank': '05', 'name': 'ZenithZero', 'badge': 'PRO', 'xp': '16.2K', 'wr': '72%'},
      {'rank': '06', 'name': 'PulsarPanda', 'badge': '', 'xp': '14.8K', 'wr': '69%'},
      {'rank': '07', 'name': 'DataDaemon', 'badge': '', 'xp': '12.1K', 'wr': '65%'},
    ];

    return Column(
      children: players.map((p) => _RankTile(player: p)).toList(),
    );
  }
}

class _RankTile extends StatelessWidget {
  final Map<String, String> player;
  const _RankTile({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KRadius.md),
        border: Border.all(color: KColors.outlineVariant.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Text(
            player['rank']!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: KColors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: KColors.surfaceContainerHigh,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              'https://api.dicebear.com/7.x/avataaars/png?seed=${player['name']}',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player['name']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: KColors.onSurface,
                      ),
                    ),
                    if (player['badge']!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: player['badge'] == 'ELITE'
                              ? KColors.primary.withValues(alpha: 0.1)
                              : KColors.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(KRadius.full),
                          border: Border.all(
                            color: player['badge'] == 'ELITE'
                                ? KColors.primary.withValues(alpha: 0.2)
                                : KColors.tertiary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          player['badge']!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            color: player['badge'] == 'ELITE' ? KColors.primary : KColors.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  player['rank'] == '04' ? 'Master III' : (player['rank'] == '05' ? 'Diamond II' : 'Platinum IV'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: KColors.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${player['xp']} XP',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: KColors.onSurface,
                ),
              ),
              Text(
                '${player['wr']} WR',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: KColors.tertiaryFixed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StickyUserRank extends StatelessWidget {
  const _StickyUserRank();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(KRadius.lg),
        border: Border.all(color: KColors.primary.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KRadius.lg - 1),
        child: BackdropFilter(
          filter: ColorFilter.mode(Colors.black.withValues(alpha: 0.1), BlendMode.dstIn),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: KColors.primary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: KColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      'https://api.dicebear.com/7.x/avataaars/png?seed=Alex',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: KColors.tertiaryFixed,
                        shape: BoxShape.circle,
                        border: Border.all(color: KColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'YOU',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: KColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '#1,245',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: KColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'TOP 15% OF PLAYERS',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: KColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: KColors.primary,
                  borderRadius: BorderRadius.circular(KRadius.md),
                ),
                child: Text(
                  'CLAIM',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: KColors.onPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
