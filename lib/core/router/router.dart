import 'package:draw_hub/auth/pages/login_page.dart';
import 'package:draw_hub/auth/pages/registration_page.dart';
import 'package:draw_hub/gallery/pages/gallery_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    // Здесь будет логика проверки авторизации
    // Пока оставь null
    return null;
  },
  routes: <RouteBase>[
    // роуты для неавторизованного юзера
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

    // роуты для авторизованного юзера
    GoRoute(
      path: '/gallery',
      name: 'gallery',
      builder: (context, state) => const GalleryPage(),
    ),
  ],
);
