import 'package:draw_hub/core/providers/auth_providers.dart';
import 'package:draw_hub/core/providers/gallery_providers.dart';
import 'package:draw_hub/core/theme/app_colors.dart';
import 'package:draw_hub/features/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //bool isEmpty = false;
    final isEmpty = ref.watch(userDrawingsProvider).value?.isEmpty ?? false;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
        leading: IconButton(
          icon: const Icon(Icons.logout, color: AppColors.red),
          onPressed: () async {
            final authUseCase = ref.read(authUseCaseProvider);
            await authUseCase.logoutUseCase();
          },
        ),
        actions: isEmpty
            ? []
            : [
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.format_paint_rounded)
                ),
              ],
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/png/background_img.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
          ),
          isEmpty ? _buildEmptyGallery(context) : _buildGallery(),
        ],
      ),
    );
  }

  Widget _buildEmptyGallery(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GradientButton(onPressed: () => context.push('/drawing'), text: "Создать"),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGallery() {
    return const Center(child: Text('Gallery'));
  }
 
}
