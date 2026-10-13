import 'package:go_router/go_router.dart';

import '../../features/player/player_screen.dart';
import '../../features/playlist/presentation/import_playlist_screen.dart';
import '../../features/playlist/presentation/playlist_screen.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const PlaylistScreen(),
      ),
      GoRoute(
        path: '/import',
        builder: (context, state) => const ImportPlaylistScreen(),
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) {
          final name = state.uri.queryParameters['name'] ?? 'Canal';
          final url = state.uri.queryParameters['url'] ?? '';
          return PlayerScreen(url: url, name: name);
        },
      ),
    ],
  );
}
