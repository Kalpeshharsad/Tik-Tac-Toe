import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kinetic_tictactoe/services/peer_service.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';
import 'package:kinetic_tictactoe/router/app_router.dart';
import 'package:provider/provider.dart';

class GlobalInviteOverlay extends StatefulWidget {
  final Widget child;
  const GlobalInviteOverlay({super.key, required this.child});

  @override
  State<GlobalInviteOverlay> createState() => _GlobalInviteOverlayState();
}

class _GlobalInviteOverlayState extends State<GlobalInviteOverlay> {
  @override
  void initState() {
    super.initState();
    PeerService().addListener(_onPeerUpdate);
    PeerService().onConnectionEstablished = _onConnectionEstablished;
  }

  @override
  void dispose() {
    PeerService().removeListener(_onPeerUpdate);
    if (PeerService().onConnectionEstablished == _onConnectionEstablished) {
      PeerService().onConnectionEstablished = null;
    }
    super.dispose();
  }

  void _onPeerUpdate() {
    final svc = PeerService();
    debugPrint('GlobalInviteOverlay: Peer updated, pending: ${svc.pendingInvites.length}');
    
    // Vibrate if a new invite arrived
    if (svc.pendingInvites.isNotEmpty) {
      HapticFeedback.vibrate();
    }
    
    if (mounted) setState(() {});
  }

  void _onConnectionEstablished() {
    debugPrint('GlobalInviteOverlay: Connection established!');
    if (!mounted) return;
    
    final svc = PeerService();
    final gameState = context.read<GameState>();

    if (svc.isHost) {
      gameState.setupMultiplayer('X');
    } else {
      gameState.setupMultiplayer('O');
    }

    // Go to game board using the global router instance
    appRouter.go('/play?vsAI=false');
  }

  @override
  Widget build(BuildContext context) {
    final svc = PeerService();
    final invites = svc.pendingInvites.keys.toList();
    
    if (invites.isNotEmpty) {
      debugPrint('GlobalInviteOverlay: Building with ${invites.length} invites');
    }

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        // We ensure we only show invites if we aren't already connected
        if (invites.isNotEmpty && svc.status != PeerStatus.connected)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: invites.map((senderId) => _buildInviteCard(context, svc, senderId)).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInviteCard(BuildContext context, PeerService svc, String senderId) {
    // Look up colors manually or from context safely
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KRadius.lg),
        border: Border.all(color: colors.primary.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                senderId.substring(0, 1).toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GAME INVITE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: colors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  senderId,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.close_rounded, color: colors.error),
                onPressed: () => svc.declineInvite(senderId),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary.withValues(alpha: 0.2),
                ),
                icon: Icon(Icons.check_rounded, color: colors.primary),
                onPressed: () {
                  svc.acceptInvite(senderId);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
