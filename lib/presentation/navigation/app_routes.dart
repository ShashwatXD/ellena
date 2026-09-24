import 'package:go_router/go_router.dart';

import '../screens/home_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';

  static const String homeName = 'home';
}

List<RouteBase> get appRoutes => [
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
    ];
