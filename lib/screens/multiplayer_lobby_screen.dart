import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/widgets/kinetic_app_bar.dart';
import 'package:kinetic_tictactoe/widgets/bottom_nav_bar.dart';
import 'package:kinetic_tictactoe/widgets/player_card.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late AnimationController _pingCtrl;

  final List<Map<String, dynamic>> _players = [
    {
      'username': 'CyberLuna_99',
      'title': 'Master Tactician',
      'level': 'LVL 42',
      'isOnline': true,
      'isElite': false,
      'isOffline': false,
    },
    {
      'username': 'Jax_Volt',
      'title': 'Last played 2m ago',
      'level': 'LVL 18',
      'isOnline': true,
      'isElite': false,
      'isOffline': false,
    },
    {
      'username': 'NeoKinetiX',
      'title': 'Top 1% Global Rank',
      'level': 'PRO',
      'isOnline': true,
      'isElite': true,
      'isOffline': false,
    },
    {
      'username': 'Zora_The_Grid',
      'title': 'Win Streak: 5',
      'level': 'LVL 67',
      'isOnline': true,
      'isElite': false,
      'isOffline': false,
    },
    {
      'username': 'Sparky_Rook',
      'title': 'Offline',
      'level': 'LVL 04',
      'isOnline': false,
      'isElite': false,
      'isOffline': true,
    },
    {
      'username': 'Silent_Ghost',
      'title': 'Defense Specialist',
      'level': 'LVL 24',
      'isOnline': true,
      'isElite': false,
      'isOffline': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pingCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.surface,
      appBar: const KineticAppBar(),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildMatchmakingCard(),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 8),
                _buildPlayersHeader(),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _players.length) return null;
                  final p = _players[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlayerCard(
                      username: p['username'] as String,
                      title: p['title'] as String,
                      level: p['level'] as String,
                      isOnline: p['isOnline'] as bool,
                      isElite: p['isElite'] as bool,
                      isOffline: p['isOffline'] as bool,
                      onChallenge: () => _showChallengeDialog(
                          context, p['username'] as String),
                    ),
                  );
                },
                childCount: _players.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: _buildLoadMore(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: KineticBottomNavBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.go('/');
        },
      ),
    );
  }

  Widget _buildMatchmakingCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: KColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KRadius.lg),
      ),
      child: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KColors.primary.withValues(alpha: 0.08),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MATCHMAKING',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: KColors.onSurfaceVariant,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Searching for\nOpponent...',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: KColors.onSurface,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _pingCtrl,
                      builder: (_, __) => Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: KColors.primary
                                      .withValues(alpha: 0.3 * _pingCtrl.value),
                                ),
                              ),
                              Container(
                                width: 10, height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: KColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ETA: 0:42',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: KColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: KColors.tertiary,
                    borderRadius: BorderRadius.circular(KRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: KColors.tertiary.withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.add_box_outlined,
                          color: KColors.onTertiary, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'PRIVATE\nROOM',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: KColors.onTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FIND PLAYERS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: KColors.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: KColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KRadius.md),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.plusJakartaSans(
                    color: KColors.onSurface,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by username or ID...',
                    hintStyle: GoogleFonts.plusJakartaSans(
                      color: KColors.onSurfaceVariant.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: KColors.onSurfaceVariant, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 26),
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: KColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KRadius.md),
            ),
            child: const Icon(Icons.tune_rounded,
                color: KColors.onSurfaceVariant, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersHeader() {
    return Text(
      'ACTIVE NOW (142)',
      style: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: KColors.onSurfaceVariant,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildLoadMore() {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              'LOAD MORE PLAYERS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: KColors.onSurfaceVariant,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.expand_more_rounded,
                color: KColors.onSurfaceVariant, size: 28),
          ],
        ),
      ),
    );
  }

  void _showChallengeDialog(BuildContext context, String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: KColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KRadius.lg)),
        title: Text(
          'Challenge $username?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: KColors.onSurface,
          ),
        ),
        content: Text(
          'This feature requires a live server. For now, play vs AI!',
          style: GoogleFonts.plusJakartaSans(
            color: KColors.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.plusJakartaSans(
                    color: KColors.onSurfaceVariant)),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(ctx);
              context.go('/play');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: KColors.tertiary,
                borderRadius: BorderRadius.circular(KRadius.md),
              ),
              child: Text(
                'Play vs AI',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  color: KColors.onTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
