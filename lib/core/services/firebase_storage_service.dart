import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draw_hub/features/drawing/models/drawing_model.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class FirebaseStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Сохранение рисунка (изображение в Base64)
  Future<DrawingModel> saveDrawing({
    required File imageFile,
    required String authorId,
    required String title,
    required String authorName,
  }) async {
    try {
      // 1. Читаем файл
      final bytes = await imageFile.readAsBytes();
      
      // 2. Декодируем изображение
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Не удалось декодировать изображение');
      }

      // 3. Создаем thumbnail (уменьшенная версия для сетки)
      img.Image thumbnail = img.copyResize(
        image,
        width: 400, // Ширина для превью
        height: (400 * image.height / image.width).round(),
      );

      // 4. Сжимаем основное изображение (максимум 1024px)
      img.Image mainImage = image;
      if (image.width > 1024 || image.height > 1024) {
        mainImage = img.copyResize(
          image,
          width: 1024,
          height: (1024 * image.height / image.width).round(),
        );
      }

      // 5. Конвертируем в JPEG с качеством 80%
      final thumbnailJpg = img.encodeJpg(thumbnail, quality: 80);
      final mainImageJpg = img.encodeJpg(mainImage, quality: 85);

      // 6. Конвертируем в Base64
      final thumbnailBase64 = base64Encode(thumbnailJpg);
      final imageBase64 = base64Encode(mainImageJpg);

      // 7. Проверяем размер (Firestore лимит 1 МБ на документ)
      final thumbnailSize = thumbnailBase64.length;
      final imageSize = imageBase64.length;
      
      debugPrint('Thumbnail size: ${(thumbnailSize / 1024).toStringAsFixed(2)} KB');
      debugPrint('Image size: ${(imageSize / 1024).toStringAsFixed(2)} KB');

      if (imageSize > 900000) { // ~900 KB (оставляем запас)
        throw Exception('Изображение слишком большое. Попробуйте упростить рисунок.');
      }

      // 8. Создаем объект DrawingModel
      final drawing = DrawingModel(
        id: '',
        title: title,
        authorId: authorId,
        createdAt: DateTime.now(),
        imageUrl: 'data:image/jpeg;base64,$imageBase64',
        thumbnailUrl: 'data:image/jpeg;base64,$thumbnailBase64',
        authorName: authorName,
      );

      // 9. Сохраняем в Firestore
      final docRef = await _firestore.collection('drawings').add(
            drawing.toFirestore(),
          );

      // 10. Возвращаем объект с ID
      return DrawingModel(
        id: docRef.id,
        title: drawing.title,
        authorId: drawing.authorId,
        authorName: drawing.authorName,
        createdAt: drawing.createdAt,
        imageUrl: drawing.imageUrl,
        thumbnailUrl: drawing.thumbnailUrl,
      );
    } catch (e) {
      throw Exception('Ошибка сохранения: $e');
    }
  }

  // Удаление рисунка
  Future<void> deleteDrawing(String drawingId) async {
    try {
      await _firestore.collection('drawings').doc(drawingId).delete();
    } catch (e) {
      throw Exception('Ошибка удаления: $e');
    }
  }
}
