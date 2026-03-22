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

  bool _isHosting = false;
  bool _isJoining = false;

  Future<void> _stopAll() async {
    _nearbyService.stopAll();
    _pingCtrl.stop();
    setState(() {
      _isSearching = false;
      _isHosting = false;
      _isJoining = false;
      _discoveredDevices.clear();
    });
  }

  Future<bool> _requestPermissions() async {
    final permissions = [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ];
    
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    return !statuses.values.any((s) => s.isDenied);
  }

  Future<void> _startHosting() async {
    if (_isHosting) {
      await _stopAll();
      return;
    }
    
    if (!await _requestPermissions()) {
      _showPermissionError();
      return;
    }

    final username = Provider.of<SettingsState>(context, listen: false).userName;
    bool success = await _nearbyService.startAdvertising(username);
    
    if (success) {
      _pingCtrl.repeat(reverse: true);
      setState(() {
        _isHosting = true;
        _isSearching = true;
      });
    }
  }

  Future<void> _startJoining() async {
    if (_isJoining) {
      await _stopAll();
      return;
    }
    
    if (!await _requestPermissions()) {
      _showPermissionError();
      return;
    }

    final username = Provider.of<SettingsState>(context, listen: false).userName;
    bool success = await _nearbyService.startDiscovery(username);
    
    if (success) {
      _pingCtrl.repeat(reverse: true);
      setState(() {
        _isJoining = true;
        _isSearching = true;
      });
    }
  }

  void _showPermissionError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permissions required for Local Multiplayer')),
      );
    }
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

  Widget _buildMatchmakingButton({
    required VoidCallback onTap,
    required bool isActive,
    required bool isOtherActive,
    required IconData icon,
    required String label,
  }) {
    final color = isActive ? KColors.error : (isOtherActive ? KColors.surfaceContainerHigh : KColors.tertiary);
    final onColor = isActive ? Colors.white : (isOtherActive ? KColors.onSurfaceVariant : KColors.onTertiary);

    return GestureDetector(
      onTap: isOtherActive ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
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
        child: Column(
          children: [
            Icon(isActive ? Icons.stop_rounded : icon, color: onColor, size: 20),
            const SizedBox(height: 4),
            Text(
              isActive ? 'STOP' : label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: onColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchmakingCard() {
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
          Row(
            children: [
              Expanded(
                child: Column(
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
                      _isHosting ? 'Host Mode\nWaiting...' : (_isJoining ? 'Join Mode\nScanning...' : 'Start Local\nMatchmaking'),
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
                              color: (_isSearching) ? KColors.primary : KColors.onSurfaceVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isSearching ? 'ACTIVE' : 'IDLE',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isSearching ? KColors.primary : KColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  _buildMatchmakingButton(
                    onTap: _startHosting,
                    isActive: _isHosting,
                    isOtherActive: _isJoining,
                    icon: Icons.broadcast_on_personal_rounded,
                    label: 'HOST',
                  ),
                  const SizedBox(height: 12),
                  _buildMatchmakingButton(
                    onTap: _startJoining,
                    isActive: _isJoining,
                    isOtherActive: _isHosting,
                    icon: Icons.radar_rounded,
                    label: 'JOIN',
                  ),
                ],
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
