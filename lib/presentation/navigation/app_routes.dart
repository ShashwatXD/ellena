import 'package:go_router/go_router.dart';

import '../screens/account/account_screen.dart';
import '../screens/home/home_screen.dart';
import 'fade_slide_page.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String homeName = 'home';

  static const String account = '/account';
  static const String accountName = 'account';
}

List<RouteBase> get appRoutes => [
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.account,
        name: AppRoutes.accountName,
        pageBuilder: (context, state) => fadeSlidePage(
          state: state,
          child: const AccountScreen(),
        ),
      ),
    ];
