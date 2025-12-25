import 'package:draw_hub/features/auth/pages/login_page.dart';
import 'package:draw_hub/features/auth/pages/registration_page.dart';
import 'package:draw_hub/core/providers/auth_providers.dart';
import 'package:draw_hub/features/gallery/pages/drawing_page.dart';
import 'package:draw_hub/features/gallery/pages/gallery_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authAsync = ref.watch(authUserProvider);

      // Обрабатываем все состояния AsyncValue
      return authAsync.when(
        data: (user) {
          final isLoggedIn = user != null;
          final isOnAuthPage =
              state.matchedLocation == '/login' ||
              state.matchedLocation == '/registration';

          if (isLoggedIn && isOnAuthPage) {
            return '/gallery';
          }
          if (!isLoggedIn && !isOnAuthPage) {
            return '/login';
          }
          return null;
        },
        loading: () {
          // Во время загрузки показываем текущую страницу
          // или можно показать splash screen
          return null;
        },
        error: (error, stack) {
          return '/login';
        },
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/registration',
        name: 'registration',
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(
        path: '/gallery',
        name: 'gallery',
        builder: (context, state) => const GalleryPage(),
      ),
      GoRoute(
        path: '/drawing',
        name: 'drawing',
        builder: (context, state) => const DrawingPage(),
      ),
    ],
  );

  return router;
});
