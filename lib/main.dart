import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';
import 'package:kinetic_tictactoe/router/app_router.dart';

import 'package:kinetic_tictactoe/state/settings_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const KineticApp());
}

class KineticApp extends StatelessWidget {
  const KineticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
        ChangeNotifierProvider(create: (_) => SettingsState()),
      ],
      child: Consumer<SettingsState>(
        builder: (context, settings, _) {
          // Update status bar based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: settings.isDarkMode ? Brightness.light : Brightness.dark,
              statusBarBrightness: settings.isDarkMode ? Brightness.dark : Brightness.light,
            ),
          );

          return MaterialApp.router(
            title: 'KINETIC',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getTheme(
              settings.isDarkMode ? Brightness.dark : Brightness.light,
              settings.accentColor,
            ),
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
