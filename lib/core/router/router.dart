import 'package:draw_hub/features/auth/pages/login_page.dart';
import 'package:draw_hub/features/auth/pages/registration_page.dart';
import 'package:draw_hub/core/providers/auth_providers.dart';
import 'package:draw_hub/features/gallery/pages/gallery_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = ref.read(authStateChangesProvider);
      final isLoggedIn = authState.value != null;
      final isOnLoginPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/registration';

      if (isLoggedIn && isOnLoginPage) {
        return '/gallery';
      }

      if (!isLoggedIn && !isOnLoginPage) {
        return '/login';
      }

      return null;
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
    ],
  );

  // Слушаем изменения authState и обновляем роутер
  ref.listen(authStateChangesProvider, (_, __) {
    router.refresh(); // Принудительно обновляем роутер
  });

  return router;
});
