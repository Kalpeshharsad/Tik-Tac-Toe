import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/widgets/kinetic_app_bar.dart';
import 'package:kinetic_tictactoe/widgets/bottom_nav_bar.dart';
import 'package:kinetic_tictactoe/widgets/player_card.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kinetic_tictactoe/services/nearby_service.dart';
import 'package:provider/provider.dart';
import 'package:kinetic_tictactoe/state/settings_state.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';
import 'package:nearby_connections/nearby_connections.dart';

class MultiplayerLobbyScreen extends StatefulWidget {
  const MultiplayerLobbyScreen({super.key});

  @override
  State<MultiplayerLobbyScreen> createState() => _MultiplayerLobbyScreenState();
}

class _MultiplayerLobbyScreenState extends State<MultiplayerLobbyScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late AnimationController _pingCtrl;
  final Map<String, String> _discoveredDevices = {}; // ID -> Name
  bool _isSearching = false;
  final _nearbyService = NearbyService();

  @override
  void initState() {
    super.initState();
    _pingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Set up callbacks
    _nearbyService.onEndpointFound = (id, name) {
      debugPrint('Endpoint found: $id - $name');
      setState(() => _discoveredDevices[id] = name);
    };
    _nearbyService.onEndpointLost = (id) {
      setState(() => _discoveredDevices.remove(id));
    };
    _nearbyService.onConnectionInitiated = (id, info) {
      _showConnectionRequestDialog(id, info);
    };
    _nearbyService.onConnected = (id) {
      final gameState = Provider.of<GameState>(context, listen: false);
      // Host stays X, Joiner becomes O? 
      // Actually nearby_connections doesn't tell us who is who easily, 
      // but usually the advertiser is the host.
      final mySign = _nearbyService.status == NearbyStatus.advertising ? 'X' : 'O';
      gameState.setupMultiplayer(mySign);
      
      // Navigate to game
      if (mounted) context.go('/play');
    };
  }

  Future<void> _toggleMatchmaking() async {
    if (_isSearching) {
      _nearbyService.stopAll();
      _pingCtrl.stop();
      setState(() {
        _isSearching = false;
        _discoveredDevices.clear();
      });
      return;
    }

    // Request permissions
    final permissions = [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ];
    
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    if (!mounted) return;
    
    if (statuses.values.any((s) => s.isDenied)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions required for Local Multiplayer')),
        );
      }
      return;
    }

    final username = Provider.of<SettingsState>(context, listen: false).userName;
    
    // Start both for bidirectional discovery (simpler for users)
    await _nearbyService.startAdvertising(username);
    await _nearbyService.startDiscovery(username);

    _pingCtrl.repeat(reverse: true);
    setState(() => _isSearching = true);
  }

  void _showConnectionRequestDialog(String id, ConnectionInfo info) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: KColors.surfaceContainerHigh,
        title: const Text('Connection Request'),
        content: Text('Accept invitation from ${info.endpointName}?'),
        actions: [
          TextButton(
            onPressed: () {
              Nearby().rejectConnection(id);
              Navigator.pop(ctx);
            },
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              _nearbyService.acceptConnection(id);
              Navigator.pop(ctx);
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
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
                  if (index >= _discoveredDevices.length) return null;
                  final id = _discoveredDevices.keys.elementAt(index);
                  final name = _discoveredDevices[id]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PlayerCard(
                      username: name,
                      title: 'Nearby Device',
                      level: 'P2P',
                      isOnline: true,
                      isElite: false,
                      isOffline: false,
                      onChallenge: () {
                        final username = Provider.of<SettingsState>(context, listen: false).userName;
                        _nearbyService.invite(id, username);
                      },
                    ),
                  );
                },
                childCount: _discoveredDevices.length,
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
                      _isSearching ? 'Searching for\nOpponent...' : 'Start Local\nMultiplayer',
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
                            _isSearching ? 'ACTIVE' : 'READY',
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
                onTap: _toggleMatchmaking,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _isSearching ? KColors.error : KColors.tertiary,
                    borderRadius: BorderRadius.circular(KRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: (_isSearching ? KColors.error : KColors.tertiary).withValues(alpha: 0.2),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(_isSearching ? Icons.stop_rounded : Icons.radar_rounded,
                          color: _isSearching ? Colors.white : KColors.onTertiary, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        _isSearching ? 'STOP' : 'GO LIVE',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: _isSearching ? Colors.white : KColors.onTertiary,
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
      'NEARBY DEVICES (${_discoveredDevices.length})',
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

}
