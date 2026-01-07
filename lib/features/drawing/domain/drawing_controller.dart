import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draw_hub/core/services/firebase_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Состояние операции рисования
sealed class DrawingOperationState {
  const DrawingOperationState();
}

class DrawingOperationIdle extends DrawingOperationState {
  const DrawingOperationIdle();
}

class DrawingOperationLoading extends DrawingOperationState {
  const DrawingOperationLoading();
}

class DrawingOperationSuccess extends DrawingOperationState {
  final String? operation; // 'save', 'export', 'import'
  const DrawingOperationSuccess({this.operation});
}

class DrawingOperationError extends DrawingOperationState {
  final String message;
  const DrawingOperationError(this.message);
}

/// Точка рисования
class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final bool isEraser;

  DrawingPoint({
    required this.offset,
    required this.paint,
    required this.isEraser,
  });

  factory DrawingPoint.create({
    required Offset offset,
    Color color = Colors.black,
    double strokeWidth = 3.0,
    bool isEraser = false,
  }) {
    return DrawingPoint(
      offset: offset,
      paint: Paint()
        ..color = isEraser ? Colors.white : color
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
      isEraser: isEraser,
    );
  }
}

/// Контроллер для рисования
class DrawingController extends Notifier<DrawingState> {
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorageService _firebaseStorageService = FirebaseStorageService();

  @override
  DrawingState build() {
    return DrawingState();
  }

  /// Инициализация с фоновым изображением
  void initializeEditor({Uint8List? backgroundImage}) {
    state = state.copyWith(
      strokes: [],
      currentStroke: [],
      backgroundImage: backgroundImage,
      clearBackground: backgroundImage == null,
      operationState: const DrawingOperationIdle(),
    );
  }

  /// Создание точки для рисования
  DrawingPoint _createPoint(Offset position) {
    return DrawingPoint.create(
      offset: position,
      color: state.selectedColor,
      strokeWidth: state.selectedWidth,
      isEraser: state.isEraserMode,
    );
  }

  /// Начало штриха
  void startStroke(Offset position) {
    final point = _createPoint(position);
    state = state.copyWith(currentStroke: [point]);
  }

  /// Обновление штриха
  void updateStroke(Offset position) {
    final point = _createPoint(position);
    final updatedStroke = [...state.currentStroke, point];
    state = state.copyWith(currentStroke: updatedStroke);
  }

  /// Завершение штриха
  void endStroke() {
    if (state.currentStroke.isNotEmpty) {
      final updatedStrokes = [
        ...state.strokes,
        List<DrawingPoint>.from(state.currentStroke),
      ];
      state = state.copyWith(strokes: updatedStrokes, currentStroke: []);
    }
  }

  /// Изменение цвета
  void changeColor(Color color) {
    state = state.copyWith(selectedColor: color, isEraserMode: false);
  }

  /// Изменение толщины кисти
  void changeBrushWidth(double width) {
    state = state.copyWith(selectedWidth: width, isEraserMode: false);
  }

  /// Переключение ластика
  void toggleEraser() {
    state = state.copyWith(isEraserMode: !state.isEraserMode);
  }

  /// Очистка холста
  void clearCanvas() {
    state = state.copyWith(strokes: [], currentStroke: []);
  }

  /// Отмена последнего штриха
  void undoLastStroke() {
    if (state.strokes.isNotEmpty) {
      final updatedStrokes = List<List<DrawingPoint>>.from(state.strokes);
      updatedStrokes.removeLast();
      state = state.copyWith(strokes: updatedStrokes);
    }
  }

  /// Импорт изображения
  Future<void> importImage() async {
    try {
      state = state.copyWith(operationState: const DrawingOperationLoading());

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (image != null) {
        final imageData = await image.readAsBytes();
        state = state.copyWith(
          backgroundImage: imageData,
          operationState: const DrawingOperationSuccess(operation: 'import'),
        );
      } else {
        state = state.copyWith(operationState: const DrawingOperationIdle());
      }
    } catch (e) {
      state = state.copyWith(
        operationState: DrawingOperationError('Ошибка импорта: $e'),
      );
    }
  }

  Future<void> shareDrawing(String imagePath) async {
    final params = ShareParams(files: [XFile(imagePath)]);

    await SharePlus.instance.share(params);
  }

  /// Экспорт рисунка через нативный share
  Future<void> exportDrawing(GlobalKey repaintBoundaryKey) async {
    try {
      state = state.copyWith(operationState: const DrawingOperationLoading());

      // 1. Делаем скриншот холста
      final boundary =
          repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Не удалось получить boundary для экспорта');
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // 2. Создаём временный файл
      final tempFile = await _createTempFile(bytes);

      // 3. Шарим файл
      await shareDrawing(tempFile.path);

      // 4. Удаляем временный файл после шаринга
      await tempFile.delete();

      state = state.copyWith(operationState: const DrawingOperationSuccess());
    } catch (e) {
      state = state.copyWith(
        operationState: DrawingOperationError('Ошибка экспорта: $e'),
      );
    }
  }


  Future<void> saveDrawing(
    GlobalKey repaintBoundaryKey, {
    String? title,
  }) async {
    try {
      state = state.copyWith(operationState: const DrawingOperationLoading());

      // 1. Получаем изображение с холста
      final RenderRepaintBoundary boundary =
          repaintBoundaryKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final Uint8List imageBytes = byteData!.buffer.asUint8List();

      // 2. Получаем текущего пользователя
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }

      // 3. Определяем имя автора (сначала из FirebaseAuth, затем из Firestore users/{uid})
      final authorName = await _resolveAuthorName(user);

      // 4. Сохраняем через общий сервис (Firestore: base64 + thumbnail)
      final tempFile = await _createTempFile(imageBytes);
      await _firebaseStorageService.saveDrawing(
        imageFile: tempFile,
        authorId: user.uid,
        title: title ?? 'Рисунок ${DateTime.now().day}.${DateTime.now().month}',
        authorName: authorName,
      );
      await tempFile.delete();

      state = state.copyWith(
        operationState: const DrawingOperationSuccess(operation: 'save'),
      );
    } catch (e) {
      state = state.copyWith(
        operationState: DrawingOperationError('Ошибка сохранения: $e'),
      );
    }
  }

  Future<String> _resolveAuthorName(User user) async {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      final nameFromDb = (data?['displayName'] as String?)?.trim();
      if (nameFromDb != null && nameFromDb.isNotEmpty) {
        return nameFromDb;
      }
    } catch (_) {
      // Игнорируем и возвращаем дефолт ниже
    }

    return 'Без имени';
  }

  /// Создает временный файл для сохранения
  Future<File> _createTempFile(Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File(
      '${tempDir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Сброс состояния операции
  void resetOperationState() {
    state = state.copyWith(operationState: const DrawingOperationIdle());
  }
}

/// Состояние рисования
class DrawingState {
  final List<List<DrawingPoint>> strokes;
  final List<DrawingPoint> currentStroke;
  final Color selectedColor;
  final double selectedWidth;
  final bool isEraserMode;
  final Uint8List? backgroundImage;
  final DrawingOperationState operationState;

  const DrawingState({
    this.strokes = const [],
    this.currentStroke = const [],
    this.selectedColor = Colors.black,
    this.selectedWidth = 5.0,
    this.isEraserMode = false,
    this.backgroundImage,
    this.operationState = const DrawingOperationIdle(),
  });

  DrawingState copyWith({
    List<List<DrawingPoint>>? strokes,
    List<DrawingPoint>? currentStroke,
    Color? selectedColor,
    double? selectedWidth,
    bool? isEraserMode,
    Uint8List? backgroundImage,
    DrawingOperationState? operationState,
    bool clearBackground = false,
  }) {
    return DrawingState(
      strokes: strokes ?? this.strokes,
      currentStroke: currentStroke ?? this.currentStroke,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedWidth: selectedWidth ?? this.selectedWidth,
      isEraserMode: isEraserMode ?? this.isEraserMode,
      backgroundImage: clearBackground
          ? null
          : (backgroundImage ?? this.backgroundImage),
      operationState: operationState ?? this.operationState,
    );
  }
}

/// Provider для DrawingController
final drawingControllerProvider =
    NotifierProvider<DrawingController, DrawingState>(
      () => DrawingController(),
    );
