import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';

/// A bento-style stat card used on Home and Results screens.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final Widget? badge;
  final Widget? footer;
  final Gradient? gradient;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = KColors.onSurface,
    this.badge,
    this.footer,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KColors.surfaceContainerLow,
        gradient: gradient,
        borderRadius: BorderRadius.circular(KRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null) ...[
            Align(alignment: Alignment.topRight, child: badge!),
            const SizedBox(height: 4),
          ],
          Text(
            label.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: KColors.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: valueColor,
              height: 1.1,
            ),
          ),
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer!,
          ],
        ],
      ),
    );
  }
}
