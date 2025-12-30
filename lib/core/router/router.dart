import 'package:draw_hub/features/auth/ui/pages/login_page.dart';
import 'package:draw_hub/features/auth/ui/pages/registration_page.dart';
import 'package:draw_hub/features/auth/ui/providers/auth_providers.dart';
import 'package:draw_hub/features/drawing/ui/pages/drawing_page.dart';
import 'package:draw_hub/features/gallery/ui/pages/fullscreen_image_page.dart';
import 'package:draw_hub/features/gallery/ui/pages/gallery_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';

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
        builder: (context, state) {
          final extra = state.extra;
          if (extra is Map<String, dynamic>) {
            final backgroundImage = extra['backgroundImage'];
            final closeOnSave = extra['closeOnSave'];
            return EditorPage(
              backgroundImage: backgroundImage is Uint8List ? backgroundImage : null,
              closeOnSave: closeOnSave is bool ? closeOnSave : false,
            );
          }

          return const EditorPage();
        },
      ),
      GoRoute(
        path: '/image-viewer',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return FullscreenImagePage(
            imageUrl: extra['imageUrl']!,
            heroTag: extra['heroTag']!,
          );
        },
      ),
    ],
  );

  return router;
});
