import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';

class PlayerCard extends StatelessWidget {
  final String username;
  final String title;
  final String level;
  final bool isOnline;
  final bool isElite;
  final bool isOffline;
  final VoidCallback? onChallenge;

  const PlayerCard({
    super.key,
    required this.username,
    required this.title,
    required this.level,
    this.isOnline = true,
    this.isElite = false,
    this.isOffline = false,
    this.onChallenge,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isElite
        ? KColors.primary.withOpacity(0.12)
        : KColors.surfaceContainerLow;
    final borderColor = isElite
        ? KColors.primary.withOpacity(0.25)
        : Colors.white.withOpacity(0.05);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(KRadius.lg),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + Level badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: KColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(KRadius.md),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      color: isElite ? KColors.primary : KColors.onSurfaceVariant,
                      size: 28,
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isOffline
                            ? const Color(0xFF64748B)
                            : KColors.tertiaryFixed,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: KColors.surfaceContainerLow,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isElite
                      ? KColors.primary
                      : KColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(KRadius.full),
                ),
                child: Text(
                  isElite ? 'PRO' : level,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: isElite ? KColors.onPrimary : KColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Username + rank
          Text(
            username,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: KColors.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                _rankIcon(),
                size: 14,
                color: KColors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: KColors.onSurfaceVariant,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Challenge button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: isOffline ? null : onChallenge,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isOffline
                      ? KColors.surfaceContainerHighest.withOpacity(0.5)
                      : (isElite
                          ? KColors.primary
                          : KColors.surfaceBright),
                  borderRadius: BorderRadius.circular(KRadius.md),
                  border: isOffline || isElite
                      ? null
                      : Border.all(
                          color: KColors.outlineVariant.withOpacity(0.2),
                          width: 1,
                        ),
                ),
                child: Text(
                  isOffline
                      ? 'OFFLINE'
                      : (isElite ? 'CHALLENGE ELITE' : 'CHALLENGE'),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: isOffline
                        ? KColors.onSurfaceVariant.withOpacity(0.4)
                        : (isElite ? KColors.onPrimary : KColors.primary),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _rankIcon() {
    if (isElite) return Icons.star_rounded;
    if (isOffline) return Icons.schedule_rounded;
    return Icons.workspace_premium_rounded;
  }
}
