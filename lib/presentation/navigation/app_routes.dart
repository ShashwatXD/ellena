import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/account_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/chat_shell.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String homeName = 'home';

  static const String chat = '/chat/:id';
  static const String chatName = 'chat';

  static const String account = '/account';
  static const String accountName = 'account';

  static String chatPath(String id) => '/chat/$id';
}

CustomTransitionPage<void> _fadeSlidePage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

List<RouteBase> get appRoutes => [
      ShellRoute(
        builder: (context, state, child) => ChatShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: AppRoutes.homeName,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.chat,
            name: AppRoutes.chatName,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ChatScreen(conversationId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.account,
        name: AppRoutes.accountName,
        pageBuilder: (context, state) => _fadeSlidePage(
          state: state,
          child: const AccountScreen(),
        ),
      ),
    ];
