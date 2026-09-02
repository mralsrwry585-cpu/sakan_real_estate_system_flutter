import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/app_strings.dart';
import '../features/account/account_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/notifications/notifications_screen.dart';
import '../features/properties/property_details_screen.dart';
import '../features/requests/create_booking_screen.dart';
import '../features/requests/create_viewing_screen.dart';
import '../features/requests/my_requests_screen.dart';
import '../features/requests/request_success_screen.dart';
import '../features/search/search_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/splash/splash_screen.dart';
import '../models/property.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Bridges Riverpod auth changes to go_router's [GoRouter.refreshListenable]
/// so redirects re-run when the session starts or ends.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final authed = ref.read(authControllerProvider).isAuthenticated;
      final loc = state.matchedLocation;

      // Splash decides its own next destination after its animation.
      if (loc == Routes.splash) return null;

      final isAuthRoute = loc == Routes.login || loc == Routes.register;
      if (!authed && !isAuthRoute) return Routes.login;
      if (authed && isAuthRoute) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // ── Primary tabs (persistent bottom navigation) ──
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKey,
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.search,
                builder: (_, __) => const SearchScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.favorites,
                builder: (_, __) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.requests,
                builder: (_, __) => const MyRequestsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.account,
                builder: (_, __) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen routes above the shell ──
      GoRoute(
        path: '/property/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => PropertyDetailsScreen(
          propertyId: state.pathParameters['id']!,
        ),
        routes: [
          GoRoute(
            path: 'viewing',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => CreateViewingScreen(
              propertyId: state.pathParameters['id']!,
              property: state.extra as PropertyDetails?,
            ),
          ),
          GoRoute(
            path: 'booking',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => CreateBookingScreen(
              propertyId: state.pathParameters['id']!,
              property: state.extra as PropertyDetails?,
            ),
          ),
        ],
      ),
      GoRoute(
        path: Routes.requestSuccess,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra;
          if (args is! RequestSuccessArgs) {
            // Reached without args (e.g. deep link) — nothing to confirm.
            return const _MissingArgsRedirect();
          }
          return RequestSuccessScreen(args: args);
        },
      ),
      GoRoute(
        path: Routes.notifications,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text(S.somethingWentWrong)),
    ),
  );
});

/// Bounces to home on the next frame when the success screen is opened without
/// its arguments.
class _MissingArgsRedirect extends StatefulWidget {
  const _MissingArgsRedirect();

  @override
  State<_MissingArgsRedirect> createState() => _MissingArgsRedirectState();
}

class _MissingArgsRedirectState extends State<_MissingArgsRedirect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(Routes.home);
    });
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: SizedBox.shrink());
}
