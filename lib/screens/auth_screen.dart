import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/services/auth_service.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_idController.text.trim().isEmpty || _passwordController.text.isEmpty) return;

    final success = _isLogin 
        ? await AuthService().login(_idController.text.trim(), _passwordController.text)
        : await AuthService().register(_idController.text.trim(), _passwordController.text);

    if (success && mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Background Accents
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: -80,
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.2,
            right: -80,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.secondary.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    blurRadius: 120,
                    spreadRadius: 60,
                  ),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.grid_view_rounded, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'KINETIC',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'K',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Text(
                          'AUTHENTICATION',
                          style: GoogleFonts.plusJakartaSans(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter the',
                          style: GoogleFonts.plusJakartaSans(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w900,
                            fontSize: 48,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'Arena',
                          style: GoogleFonts.plusJakartaSans(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            fontSize: 48,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Glass Panel
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(KRadius.lg),
                            border: Border.all(
                              color: colorScheme.onSurface.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EMAIL OR USER ID',
                                style: GoogleFonts.plusJakartaSans(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(KRadius.md),
                                ),
                                child: TextField(
                                  controller: _idController,
                                  style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurface),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    hintText: 'name@kinetic.play',
                                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                                    suffixIcon: Icon(Icons.alternate_email, color: colorScheme.onSurfaceVariant),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PASSWORD',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 10,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  if (_isLogin)
                                    Text(
                                      'Forgot Password?',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(KRadius.md),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: GoogleFonts.plusJakartaSans(color: colorScheme.onSurface),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    hintText: '••••••••',
                                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(KRadius.md),
                                    ),
                                    elevation: 8,
                                    shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isLogin ? 'SIGN IN' : 'CREATE ACCOUNT',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.bolt, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: TextButton(
                                  onPressed: () => setState(() => _isLogin = !_isLogin),
                                  child: RichText(
                                    text: TextSpan(
                                      text: _isLogin ? "Don't have an arena pass? " : "Already have a pass? ",
                                      style: GoogleFonts.plusJakartaSans(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: _isLogin ? 'Create Account' : 'Sign In',
                                          style: TextStyle(
                                            color: colorScheme.tertiary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
