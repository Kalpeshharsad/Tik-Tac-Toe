import 'package:go_router/go_router.dart';
import 'package:kinetic_tictactoe/screens/home_screen.dart';
import 'package:kinetic_tictactoe/screens/game_board_screen.dart';
import 'package:kinetic_tictactoe/screens/game_results_screen.dart';
import 'package:kinetic_tictactoe/screens/multiplayer_lobby_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
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
  ],
);
