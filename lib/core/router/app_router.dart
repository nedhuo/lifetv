import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/player/presentation/pages/player_page.dart';
import '../../features/source/presentation/pages/source_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'favorites',
            name: 'favorites',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: 'history',
            name: 'history',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: 'player/:id',
            name: 'player',
            builder: (context, state) => PlayerPage(
              videoId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: 'source',
            name: 'source',
            builder: (context, state) => const SourcePage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('页面不存在: ${state.error}'),
      ),
    ),
  );
});