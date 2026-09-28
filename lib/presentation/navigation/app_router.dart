import 'package:go_router/go_router.dart';

import '../../data/storage/app_storage.dart';
import '../../data/storage/storage_keys.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppStorage.read<bool>(StorageKeys.signedIn) == true
      ? AppRoutes.home
      : AppRoutes.welcome,
  routes: appRoutes,
);
