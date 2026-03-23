import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/widgets/bottom_nav_bar.dart';
import 'package:kinetic_tictactoe/state/settings_state.dart';
import 'package:provider/provider.dart';

import 'package:kinetic_tictactoe/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _gameInvites = true;
  bool _rankUpdates = false;

  void _showEditNameDialog(BuildContext context, SettingsState settings) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainerHigh,
        title: Text(
          'Edit Name',
          style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurface, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.plusJakartaSans(color: colorScheme.onSurfaceVariant),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: settings.accentColor)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: settings.accentColor, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                settings.updateUserName(controller.text);
              }
              Navigator.pop(context);
            },
            child: Text('SAVE', style: GoogleFonts.plusJakartaSans(color: settings.accentColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsState>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      bottomNavigationBar: KineticBottomNavBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/play');
          if (i == 2) context.go('/settings');
        },
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
            color: colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.grid_view_rounded, color: settings.accentColor, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  'KINETIC',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: settings.accentColor,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildSectionHeader('Account', 'PROFILE MANAGEMENT'),
                  const SizedBox(height: 12),
                  _buildAccountBento(settings),

                  const SizedBox(height: 32),

                  // Theme Section
                  _buildSectionHeader('Theme', 'APPEARANCE'),
                  const SizedBox(height: 12),
                  _buildThemeBento(settings),

                  const SizedBox(height: 32),

                  // Game Settings
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Game Settings', ''),
                            const SizedBox(height: 12),
                            _buildToggleGroup([
                              _ToggleItem(
                                icon: Icons.volume_up_rounded,
                                label: 'Sound FX',
                                value: settings.soundFxEnabled,
                                onChanged: settings.toggleSoundFx,
                              ),
                              _ToggleItem(
                                icon: Icons.vibration_rounded,
                                label: 'Haptics',
                                value: settings.hapticsEnabled,
                                onChanged: settings.toggleHaptics,
                              ),
                            ], settings),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Notifications', ''),
                            const SizedBox(height: 12),
                            _buildToggleGroup([
                              _ToggleItem(
                                icon: Icons.sports_esports_rounded,
                                label: 'Invites',
                                subtitle: 'PUSH',
                                value: _gameInvites,
                                onChanged: (v) => setState(() => _gameInvites = v),
                              ),
                              _ToggleItem(
                                icon: Icons.trending_up_rounded,
                                label: 'Rankings',
                                subtitle: 'WEEKLY',
                                value: _rankUpdates,
                                onChanged: (v) => setState(() => _rankUpdates = v),
                              ),
                            ], settings),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),
                  Center(
                    child: Text(
                      'KINETIC ENGINE V2.4.0',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        letterSpacing: 3,
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
      ],
    );
  }

  Widget _buildAccountBento(SettingsState settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // User Profile Card
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _showEditNameDialog(context, settings),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(KRadius.md),
                border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surfaceBright,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: settings.userName == 'Guest'
                            ? Icon(Icons.person_rounded, color: settings.accentColor, size: 32)
                            : Image.network(
                                'https://api.dicebear.com/7.x/avataaars/png?seed=${settings.userName}',
                                fit: BoxFit.cover,
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: colorScheme.tertiary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.surface, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.userName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          settings.userRank,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_rounded, color: settings.accentColor.withValues(alpha: 0.5), size: 18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Logout Button
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTap: () async {
              await AuthService().logout();
              settings.logout(); // Keep settings reset
              if (!mounted) return;
              context.go('/auth');
            },
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KRadius.md),
                border: Border.all(color: colorScheme.errorContainer.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: colorScheme.error, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    'LOGOUT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.error,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeBento(SettingsState settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KRadius.md),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Dark/Light Toggle
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(KRadius.full),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ModeBtn(
                    label: 'Dark Mode',
                    icon: Icons.dark_mode_rounded,
                    isActive: settings.isDarkMode,
                    onTap: () => settings.setDarkMode(true),
                  ),
                ),
                Expanded(
                  child: _ModeBtn(
                    label: 'Light Mode',
                    icon: Icons.light_mode_rounded,
                    isActive: !settings.isDarkMode,
                    onTap: () => settings.setDarkMode(false),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Accent Picker
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'PRIMARY ACCENT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _AccentDot(
                color: const Color(0xFF81ECFF),
                label: 'Cyan',
                isActive: settings.selectedAccentLabel == 'Cyan',
                onTap: () => settings.updateAccentColor(const Color(0xFF81ECFF), 'Cyan'),
              ),
              _AccentDot(
                color: const Color(0xFFBF5AF2),
                label: 'Purple',
                isActive: settings.selectedAccentLabel == 'Purple',
                onTap: () => settings.updateAccentColor(const Color(0xFFBF5AF2), 'Purple'),
              ),
              _AccentDot(
                color: const Color(0xFFFD9000),
                label: 'Solar',
                isActive: settings.selectedAccentLabel == 'Solar',
                onTap: () => settings.updateAccentColor(const Color(0xFFFD9000), 'Solar'),
              ),
              _AccentDot(
                color: const Color(0xFF3FFF8B),
                label: 'Acid',
                isActive: settings.selectedAccentLabel == 'Acid',
                onTap: () => settings.updateAccentColor(const Color(0xFF3FFF8B), 'Acid'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleGroup(List<_ToggleItem> items, SettingsState settings) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(KRadius.md),
      ),
      child: Column(
        children: items.map((item) {
          final isLast = items.indexOf(item) == items.length - 1;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isLast ? null : Border(bottom: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: settings.accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.label,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (item.subtitle != null)
                        Text(
                          item.subtitle!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1,
                          ),
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => item.onChanged(!item.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.value ? settings.accentColor : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(KRadius.full),
                      boxShadow: item.value
                          ? [
                              BoxShadow(
                                color: settings.accentColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                              )
                            ]
                          : [],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: item.value ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: item.value ? Colors.white : colorScheme.outline,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ModeBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeBtn({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.read<SettingsState>();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.surfaceBright : Colors.transparent,
          borderRadius: BorderRadius.circular(KRadius.full),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isActive ? settings.accentColor : colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: isActive ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AccentDot({
    required this.color,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = context.watch<SettingsState>();
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: isActive ? Border.all(color: settings.isDarkMode ? Colors.white : Colors.black, width: 3) : null,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: isActive ? 0.4 : 0.1),
                  blurRadius: isActive ? 15 : 5,
                  spreadRadius: isActive ? 2 : 0,
                )
              ],
            ),
            child: isActive
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: isActive ? settings.accentColor : colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  _ToggleItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });
}
