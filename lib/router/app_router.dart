import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/screens/home_screen.dart';
import 'package:kinetic_tictactoe/screens/game_board_screen.dart';
import 'package:kinetic_tictactoe/screens/game_results_screen.dart';
import 'package:kinetic_tictactoe/screens/multiplayer_lobby_screen.dart';
import 'package:kinetic_tictactoe/screens/leaderboard_screen.dart';
import 'package:kinetic_tictactoe/screens/settings_screen.dart';
import 'package:kinetic_tictactoe/screens/auth_screen.dart';
import 'package:kinetic_tictactoe/services/auth_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: AuthService(),
  redirect: (context, state) {
    final isAuthenticated = AuthService().isAuthenticated;
    final isAuthRoute = state.uri.path == '/auth';

    if (!isAuthenticated && !isAuthRoute) {
      return '/auth';
    }
    if (isAuthenticated && isAuthRoute) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/play',
      name: 'play',
      builder: (context, state) {
        final vsAI = state.uri.queryParameters['vsAI'] != 'false';
        return GameBoardScreen(vsAI: vsAI);
      },
    ),
    GoRoute(
      path: '/results',
      name: 'results',
      builder: (context, state) => const GameResultsScreen(),
    ),
    GoRoute(
      path: '/lobby',
      name: 'lobby',
      builder: (context, state) => const MultiplayerLobbyScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      name: 'leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
