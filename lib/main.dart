import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:kinetic_tictactoe/theme/app_theme.dart';
import 'package:kinetic_tictactoe/state/game_state.dart';
import 'package:kinetic_tictactoe/router/app_router.dart';

import 'package:kinetic_tictactoe/state/settings_state.dart';
import 'package:kinetic_tictactoe/services/auth_service.dart';
import 'package:kinetic_tictactoe/services/peer_service.dart';
import 'package:kinetic_tictactoe/widgets/global_invite_overlay.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kinetic_tictactoe/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with error handling for when config files are missing
  try {
    await Firebase.initializeApp();
    
    // Connect to Firestore emulator if in debug mode
    if (kDebugMode) {
      try {
        FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
        debugPrint('Connected to Firestore Emulator at 127.0.0.1:8080');
      } catch (e) {
        debugPrint('Failed to connect to Firestore Emulator: $e');
      }
    }
    
    await NotificationService().init();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Ensure google-services.json and GoogleService-Info.plist are provided.');
  }

  await AuthService().init();
  PeerService().initPeer();

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
            builder: (context, child) {
              return GlobalInviteOverlay(child: child!);
            },
          );
        },
      ),
    );
  }
}

