import 'package:flutter/material.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';

class GameTile extends StatefulWidget {
  final String? value; // null, 'X', or 'O'
  final VoidCallback? onTap;
  final bool isWinning;

  const GameTile({
    super.key,
    this.value,
    this.onTap,
    this.isWinning = false,
  });

  @override
  State<GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<GameTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );
  }

  @override
  void didUpdateWidget(GameTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null && oldWidget.value == null) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isX = widget.value == 'X';
    final isEmpty = widget.value == null;

    // Winning tile glow
    Color glowColor = Colors.transparent;
    if (widget.isWinning) {
      glowColor = isX
          ? KColors.primary.withOpacity(0.25)
          : KColors.secondary.withOpacity(0.25);
    }

    return GestureDetector(
      onTap: isEmpty ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isWinning
              ? (isX
                  ? KColors.primary.withOpacity(0.08)
                  : KColors.secondary.withOpacity(0.08))
              : KColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KRadius.md),
          boxShadow: widget.isWinning
              ? [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
          border: Border.all(
            color: KColors.outlineVariant.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: isEmpty
            ? const SizedBox()
            : FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Center(
                    child: isX
                        ? ShaderMask(
                            shaderCallback: (bounds) =>
                                KGradients.primary.createShader(bounds),
                            child: Text(
                              'X',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w900,
                                fontSize: 52,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ShaderMask(
                            shaderCallback: (bounds) =>
                                KGradients.secondary.createShader(bounds),
                            child: Text(
                              'O',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w900,
                                fontSize: 52,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
      ),
    );
  }
}
