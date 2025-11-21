import 'package:draw_hub/auth/usecases/auth_usecase.dart';
import 'package:draw_hub/core/providers/auth_providers.dart';
import 'package:draw_hub/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("gallery"),
          FilledButton(
            onPressed: () async {
              // Читаем AuthUseCase из провайдера
              final authUseCase = ref.read(authUseCaseProvider);
              await authUseCase.logoutUseCase();

            },
            child: const Text('logout'),
          ),
        ],
      ),
    );
  }
}
