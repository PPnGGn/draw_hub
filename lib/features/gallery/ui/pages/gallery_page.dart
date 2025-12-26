import 'dart:convert';
import 'package:draw_hub/features/auth/ui/providers/auth_providers.dart';
import 'package:draw_hub/features/gallery/ui/providers/gallery_providers.dart';
import 'package:draw_hub/core/theme/app_colors.dart';
import 'package:draw_hub/features/drawing/models/drawing_model.dart';
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
          error: (_, _) => null,
        ),
      ),
      body: drawingsAsync.when(
        data: (drawings) {
          return Stack(
            children: [
              // Фон
              Image.asset(
                'assets/png/background_img.png',
                fit: BoxFit.cover,
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
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
        error: (error, stack) {
          debugPrint('Gallery error: $error');
          debugPrint('Stack trace: $stack');

          return Stack(
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
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
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
          );
        },
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 колонки
          crossAxisSpacing: 16, // Горизонтальный отступ
          mainAxisSpacing: 16, // Вертикальный отступ
          childAspectRatio: 0.75, // Соотношение ширина/высота (3:4)
        ),
        itemCount: drawings.length,
        itemBuilder: (context, index) {
          final drawing = drawings[index];
          return _buildDrawingCard(drawing, context);
        },
      ),
    );
  }

  // Карточка рисунка
  Widget _buildDrawingCard(DrawingModel drawing, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Открыть редактор с этим рисунком
        // context.push('/drawing', extra: drawing);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Открыть: ${drawing.title}')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Превью изображения
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildImagePreview(drawing),
              ),
            ),

            // Информация о рисунке
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drawing.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(drawing.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Превью изображения
  Widget _buildImagePreview(DrawingModel drawing) {
    // Если есть thumbnail - показываем его
    if (drawing.thumbnailUrl != null && drawing.thumbnailUrl!.isNotEmpty) {
      // Проверяем что это Base64
      if (drawing.thumbnailUrl!.startsWith('data:image')) {
        return _buildBase64Image(drawing.thumbnailUrl!);
      }
      
      // Если это обычный URL (на случай если потом добавите Storage)
      return Image.network(
        drawing.thumbnailUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    // Если есть основное изображение - показываем его
    if (drawing.imageUrl.isNotEmpty) {
      if (drawing.imageUrl.startsWith('data:image')) {
        return _buildBase64Image(drawing.imageUrl);
      }

      return Image.network(
        drawing.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    // Если нет изображения - показываем заглушку
    return _buildPlaceholder();
  }

  // Отображение Base64 изображения
  Widget _buildBase64Image(String base64String) {
    try {
      // Убираем префикс "data:image/jpeg;base64," или "data:image/png;base64,"
      final base64Data = base64String.split(',').last;
      final bytes = base64Decode(base64Data);

      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error displaying base64 image: $error');
          return _buildPlaceholder();
        },
      );
    } catch (e) {
      debugPrint('Error decoding base64: $e');
      return _buildPlaceholder();
    }
  }

  // Заглушка для изображения
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.image,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }

  // Форматирование даты
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн. назад';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks нед. назад';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months мес. назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}
