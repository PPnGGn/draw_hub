import 'package:draw_hub/core/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/png/background_img.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
          ),
          Column(
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
        ],
      ),
    );
  }
}
