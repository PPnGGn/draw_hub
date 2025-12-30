import 'dart:convert';
import 'package:draw_hub/features/auth/ui/providers/auth_providers.dart';
import 'package:draw_hub/features/gallery/ui/providers/gallery_providers.dart';
import 'package:draw_hub/core/theme/app_colors.dart';
import 'package:draw_hub/features/drawing/models/drawing_model.dart';
import 'package:draw_hub/features/gallery/ui/widgets/gallery_shimmer_widget.dart';
import 'package:draw_hub/features/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingsAsync = ref.watch(userDrawingsProvider);

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
        actions: drawingsAsync.when(
          data: (drawings) => drawings.isNotEmpty
              ? [
                  IconButton(
                    onPressed: () => context.push('/drawing'),
                    icon: const Icon(Icons.format_paint_rounded),
                    tooltip: 'Создать',
                  ),
                ]
              : null,
          loading: () => null,
          error: (error, stackTrace) => null,
        ),
      ),
      body: drawingsAsync.when(
        data: (drawings) {
          return Stack(
            children: [
              // Фон
              Image.asset(
                'assets/png/background_img.png',
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),

              // Контент
              drawings.isEmpty
                  ? _buildEmptyGallery(context)
                  : _buildGallery(drawings, context),
            ],
          );
        },
        loading: () => Stack(
          children: [
            Image.asset(
              'assets/png/background_img.png',
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
            const GalleryShimmer(),
          ],
        ),
        error: (error, stack) => Stack(
          children: [
            Image.asset(
              'assets/png/background_img.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Ошибка загрузки: $error',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(userDrawingsProvider),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Пустая галерея
  Widget _buildEmptyGallery(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GradientButton(
            onPressed: () => context.push('/drawing'),
            text: "Создать",
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Галерея с рисунками
  Widget _buildGallery(List<DrawingModel> drawings, BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 24,
        bottom: 16.0,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: drawings.length,
      itemBuilder: (context, index) {
        final drawing = drawings[index];
        return _buildDrawingCard(drawing, context, index); // ✅ Передаём index
      },
    );
  }

  // Карточка рисунка
  Widget _buildDrawingCard(
    DrawingModel drawing,
    BuildContext context,
    int index,
  ) {
    final heroTag = 'gallery_image_${drawing.id}_$index';

    return GestureDetector(
      onTap: () async {
        final imageUrl = drawing.imageUrl.isNotEmpty
            ? drawing.imageUrl
            : drawing.thumbnailUrl ?? '';

        // Прогреваем изображение ДО навигации, чтобы Hero-переход не начинался с "пустого" кадра.
        // Это снижает вероятность чёрного экрана/рывка в начале анимации.
        final ImageProvider? provider = _tryBuildImageProvider(imageUrl);
        if (provider != null) {
          try {
            await precacheImage(provider, context);
          } catch (_) {
            // ignore
          }
        }

        if (!context.mounted) return;

        context.push(
          '/image-viewer',
          extra: {
            'imageUrl': imageUrl,
            'heroTag': heroTag,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            child: _buildImage(drawing), // ✅ Простой метод без навигации
          ),
        ),
      ),
    );
  }

  // Отображение изображения (без навигации!)
  Widget _buildImage(DrawingModel drawing) {
    final imageUrl = drawing.imageUrl.isNotEmpty
        ? drawing.imageUrl
        : drawing.thumbnailUrl ?? '';

    // Base64 изображение
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }

    // Network изображение
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
    );
  }

  // Заглушка для изображения
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 48, color: Colors.grey),
      ),
    );
  }

  ImageProvider? _tryBuildImageProvider(String imageUrl) {
    // Base64 изображение
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Data = imageUrl.split(',').last;
        final bytes = base64Decode(base64Data);
        return MemoryImage(bytes);
      } catch (_) {
        return null;
      }
    }

    // Network изображение
    if (imageUrl.isNotEmpty) {
      return NetworkImage(imageUrl);
    }

    return null;
  }
}
