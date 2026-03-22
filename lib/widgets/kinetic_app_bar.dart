import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';

class KineticAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLeaderboardTap;
  final Widget? leadingWidget;

  const KineticAppBar({
    super.key,
    this.onLeaderboardTap,
    this.leadingWidget,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: KColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avatar + Brand
            Row(
              children: [
                leadingWidget ??
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: KColors.surfaceContainerHigh,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: KColors.outlineVariant.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: KColors.primary,
                        size: 20,
                      ),
                    ),
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
            // Leaderboard icon
            GestureDetector(
              onTap: onLeaderboardTap,
              child: const Icon(
                Icons.leaderboard_outlined,
                color: KColors.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
