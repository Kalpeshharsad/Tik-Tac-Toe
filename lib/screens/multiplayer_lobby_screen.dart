import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/widgets/kinetic_app_bar.dart';
import 'package:kinetic_tictactoe/widgets/bottom_nav_bar.dart';
import 'package:kinetic_tictactoe/services/peer_service.dart';
import 'package:kinetic_tictactoe/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure PeerService is initialized
    PeerService().initPeer();
    
    // Listen for connection establishment to transition to game
    PeerService().onConnectionEstablished = _onConnectionEstablished;
  }

  void _onConnectionEstablished() {
    if (!mounted) return;
    final svc = PeerService();
    final gameState = context.read<GameState>();
    
    // If I am the host (I sent the invite), setup as X.
    if (svc.isHost) {
      gameState.setupMultiplayer('X');
    } else {
      gameState.setupMultiplayer('O');
    }
    
    context.go('/play?vsAI=false');
  }

  void _sendInvite() {
    final targetId = _searchCtrl.text.trim();
    if (targetId.isEmpty) return;
    
    // Prevent inviting self
    if (targetId == AuthService().currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You cannot invite yourself.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    PeerService().sendInvite(targetId);
  }

  @override
  void dispose() {
    PeerService().onConnectionEstablished = null;
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const KineticAppBar(),
      body: AnimatedBuilder(
        animation: PeerService(),
        builder: (context, _) {
          final svc = PeerService();
          final myId = AuthService().currentUserId ?? 'Guest';
          
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    // My ID Display
                    _buildMyIdCard(myId, colorScheme),
                    const SizedBox(height: 32),
                    
                    // Search and Invite
                    _buildSearchCard(svc, colorScheme),
                    const SizedBox(height: 32),

                    // Pending Invites list
                    if (svc.pendingInvites.isNotEmpty)
                      _buildPendingInvitesList(svc, colorScheme),

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

  Widget _buildMyIdCard(String myId, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KRadius.lg),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR KINETIC ID',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(KRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  myId,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: colors.primary,
                    letterSpacing: 1,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.copy_rounded, color: colors.onSurfaceVariant),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: myId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ID copied to clipboard'), duration: const Duration(seconds: 2)),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Share this ID with friends so they can invite you.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard(PeerService svc, ColorScheme colors) {
    final isConnecting = svc.status == PeerStatus.connecting && svc.outgoingInviteTo != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KRadius.lg),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVITE PLAYER',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colors.onSurfaceVariant,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KRadius.md),
            ),
            child: TextField(
              controller: _searchCtrl,
              enabled: !isConnecting,
              style: GoogleFonts.plusJakartaSans(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter Player ID',
                hintStyle: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.4)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                suffixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isConnecting ? null : _sendInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: isConnecting ? colors.surfaceContainerHighest : colors.primary,
                foregroundColor: isConnecting ? colors.onSurfaceVariant : colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KRadius.md)),
              ),
              child: isConnecting 
                  ? Text('WAITING FOR ${svc.outgoingInviteTo}...')
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.send_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'SEND INVITE',
                          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                      ],
                    ),
            ),
          ),
          if (isConnecting) ...[
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => svc.stopAll(), // Cancel invite
                child: Text('CANCEL', style: TextStyle(color: colors.error)),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPendingInvitesList(PeerService svc, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PENDING INVITES',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: colors.onSurfaceVariant,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        ...svc.pendingInvites.keys.map((senderId) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(KRadius.md),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
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
                  child: Text(
                    senderId,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
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
                      icon: Icon(Icons.check_rounded, color: colors.primary),
                      onPressed: () => svc.acceptInvite(senderId),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
