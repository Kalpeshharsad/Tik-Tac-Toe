import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/widgets/kinetic_app_bar.dart';
import 'package:kinetic_tictactoe/widgets/bottom_nav_bar.dart';
import 'package:kinetic_tictactoe/services/peer_service.dart';
import 'package:provider/provider.dart';
import 'package:kinetic_tictactoe/state/settings_state.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen>
    with SingleTickerProviderStateMixin {
  final _codeCtrl = TextEditingController();
  late AnimationController _pingCtrl;

  @override
  void initState() {
    super.initState();
    _pingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Initial sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncPeerState();
    });
  }

  void _syncPeerState() {
    final svc = PeerService();
    if (svc.status == PeerStatus.hosting || svc.status == PeerStatus.connecting) {
      _pingCtrl.repeat(reverse: true);
    } else {
      _pingCtrl.stop();
    }
  }

  void _stopAll() {
    PeerService().stopAll();
    _pingCtrl.stop();
    setState(() {});
  }

  void _startHosting() {
    if (PeerService().status != PeerStatus.idle) {
      _stopAll();
      return;
    }

    final username = context.read<SettingsState>().userName;
    final svc = PeerService();
    
    svc.onConnectionEstablished = () {
      final gameState = context.read<GameState>();
      // Host is always X
      gameState.setupMultiplayer('X');
      if (mounted) context.go('/play?vsAI=false');
    };

    svc.startHosting(username);
    _syncPeerState();
    setState(() {});
  }

  void _startJoining() {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-character room code'), backgroundColor: KColors.error),
      );
      return;
    }

    if (PeerService().status != PeerStatus.idle) {
      _stopAll();
      return;
    }

    final username = context.read<SettingsState>().userName;
    final svc = PeerService();

    svc.onConnectionEstablished = () {
      final gameState = context.read<GameState>();
      // Joiner is always O
      gameState.setupMultiplayer('O');
      if (mounted) context.go('/play?vsAI=false');
    };

    svc.joinRoom(username, code);
    _syncPeerState();
    setState(() {});
  }

  @override
  void dispose() {
    _pingCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We listen to PeerService changes manually or use AnimatedBuilder
    return Scaffold(
      backgroundColor: KColors.surface,
      appBar: const KineticAppBar(),
      body: AnimatedBuilder(
        animation: PeerService(),
        builder: (context, _) {
          final svc = PeerService();
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMatchmakingCard(svc),
                    const SizedBox(height: 32),
                    if (svc.status == PeerStatus.hosting)
                      _buildHostView(svc)
                    else if (svc.status == PeerStatus.idle || svc.status == PeerStatus.connecting)
                      _buildJoinView(svc),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: KineticBottomNavBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) context.go('/');
        },
      ),
    );
  }

  Widget _buildMatchmakingButton({
    required VoidCallback onTap,
    required bool isActive,
    required bool isOtherActive,
    required IconData icon,
    required String label,
  }) {
    final color = isActive ? KColors.error : (isOtherActive ? KColors.surfaceContainerHigh : KColors.primary);
    final onColor = isActive ? Colors.white : (isOtherActive ? KColors.onSurfaceVariant : KColors.surfaceContainerHigh);

    return GestureDetector(
      onTap: isOtherActive ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(KRadius.md),
          boxShadow: isActive ? [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ] : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? Icons.cancel_rounded : icon, color: onColor, size: 20),
            const SizedBox(width: 8),
            Text(
              isActive ? 'CANCEL MATCHMAKING' : label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: onColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchmakingCard(PeerService svc) {
    final isHosting = svc.status == PeerStatus.hosting;
    final isConnecting = svc.status == PeerStatus.connecting;

    String titleText = 'Online\nMatchmaking';
    if (isHosting) titleText = 'Host Mode\nWaiting...';
    if (isConnecting) titleText = 'Join Mode\nConnecting...';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KRadius.lg),
      ),
      child: Stack(
        children: [
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MULTIPLAYER LOBBY',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: KColors.onSurfaceVariant,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                titleText,
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
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isHosting || isConnecting) ? KColors.primary : KColors.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (isHosting || isConnecting) ? 'ACTIVE' : 'IDLE',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: (isHosting || isConnecting) ? KColors.primary : KColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildMatchmakingButton(
                      onTap: _startHosting,
                      isActive: isHosting,
                      isOtherActive: isConnecting,
                      icon: Icons.add_circle_outline_rounded,
                      label: 'HOST GAME',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHostView(PeerService svc) {
    return Column(
      children: [
        Text(
          'YOUR ROOM CODE',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: KColors.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: KColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KRadius.lg),
            border: Border.all(color: KColors.primary.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: KColors.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ]
          ),
          child: Text(
            svc.currentRoomCode ?? '------',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
              color: KColors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Share this code with your opponent.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: KColors.onSurfaceVariant,
          ),
        )
      ],
    );
  }

  Widget _buildJoinView(PeerService svc) {
    final isConnecting = svc.status == PeerStatus.connecting;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JOIN A GAME',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: KColors.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: KColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KRadius.md),
            border: Border.all(
              color: KColors.outlineVariant.withValues(alpha: 0.2),
            )
          ),
          child: TextField(
            controller: _codeCtrl,
            enabled: !isConnecting,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            style: GoogleFonts.plusJakartaSans(
              color: KColors.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'ENTER CODE',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: KColors.onSurfaceVariant.withValues(alpha: 0.3),
                fontSize: 24,
                letterSpacing: 4,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 24),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildMatchmakingButton(
          onTap: _startJoining,
          isActive: isConnecting,
          isOtherActive: false,
          icon: Icons.login_rounded,
          label: 'JOIN GAME',
        ),
      ],
    );
  }
}
