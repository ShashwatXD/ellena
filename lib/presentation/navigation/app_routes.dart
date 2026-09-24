import 'package:go_router/go_router.dart';

import '../screens/chat_screen.dart';
import '../screens/home_screen.dart';
import '../widgets/chat_shell.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String homeName = 'home';

  static const String chat = '/chat/:id';
  static const String chatName = 'chat';

  static String chatPath(String id) => '/chat/$id';
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
    ];
