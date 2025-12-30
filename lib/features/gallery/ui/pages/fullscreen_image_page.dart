import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FullscreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullscreenImagePage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              final bytes = _tryDecodeToBytes(imageUrl);
              if (bytes == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Не удалось подготовить изображение для редактирования')),
                );
                return;
              }

              context.push(
                '/drawing',
                extra: {
                  'backgroundImage': bytes,
                  'closeOnSave': true,
                },
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Редактировать',
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
            // Для "открытия" берём виджет из grid (квадрат + ClipRRect).
            // Для "закрытия" тоже берём grid-виджет, чтобы не было эффекта
            // "прямоугольник долетел и в конце стал квадратным".
            return fromHeroContext.widget;
          },
          child: Material(
            type: MaterialType.transparency,
            child: ColoredBox(
              color: Colors.black,
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(child: _buildImage(context)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    // Base64 изображение
    if (imageUrl.startsWith('data:image')) {
      final base64Data = imageUrl.split(',').last;
      final bytes = base64Decode(base64Data);
      return Image.memory(
        bytes,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        gaplessPlayback: true,
      );
    }
    // Network изображение
    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const ColoredBox(color: Colors.black);
      },
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(color: Colors.black);
      },
    );
  }

  Uint8List? _tryDecodeToBytes(String url) {
    if (url.startsWith('data:image')) {
      try {
        final base64Data = url.split(',').last;
        return base64Decode(base64Data);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
