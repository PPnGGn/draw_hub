import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  // Запрос разрешения для галереи
  Future<bool> _requestGalleryPermission() async {
    PermissionStatus status;

    status = await Permission.photos.request();

    return status.isGranted;
  }

  // Запрос разрешения для камеры
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  // Загрузка из галереи
  Future<File?> pickImageFromGallery() async {
    try {
      final hasPermission = await _requestGalleryPermission();

      if (!hasPermission) {
        throw Exception('Нет доступа к галерее');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      rethrow;
    }
  }

  // Фото с камеры
  Future<File?> pickImageFromCamera() async {
    try {
      final hasPermission = await _requestCameraPermission();

      if (!hasPermission) {
        throw Exception('Нет доступа к камере');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image == null) return null;

      return File(image.path);
    } catch (e) {
      rethrow;
    }
  }
}
