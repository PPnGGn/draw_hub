import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:draw_hub/features/auth/ui/providers/auth_providers.dart';
import 'package:draw_hub/features/gallery/ui/providers/gallery_providers.dart';

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
  const DrawingOperationSuccess();
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
      final updatedStrokes = [...state.strokes, List<DrawingPoint>.from(state.currentStroke)];
      state = state.copyWith(
        strokes: updatedStrokes,
        currentStroke: [],
      );
    }
  }

  /// Изменение цвета
  void changeColor(Color color) {
    state = state.copyWith(
      selectedColor: color,
      isEraserMode: false,
    );
  }

  /// Изменение толщины кисти
  void changeBrushWidth(double width) {
    state = state.copyWith(
      selectedWidth: width,
      isEraserMode: false,
    );
  }

  /// Переключение ластика
  void toggleEraser() {
    state = state.copyWith(isEraserMode: !state.isEraserMode);
  }

  /// Очистка холста
  void clearCanvas() {
    state = state.copyWith(
      strokes: [],
      currentStroke: [],
    );
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

      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageData = await image.readAsBytes();
        state = state.copyWith(
          backgroundImage: imageData,
          operationState: const DrawingOperationSuccess(),
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

  /// Сохранение рисунка
  Future<void> saveDrawing(GlobalKey repaintBoundaryKey) async {
    try {
      state = state.copyWith(operationState: const DrawingOperationLoading());

      // 1. Получаем текущего пользователя
      final currentUser = ref.read(authUserProvider).value;
      if (currentUser == null) {
        throw Exception('Пользователь не авторизован');
      }

      // 2. Создаем скриншот холста
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Не удалось получить boundary для экспорта');
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // 3. Сохраняем через Firebase Storage Service
      final storageService = ref.read(firebaseStorageServiceProvider);
      final tempFile = await _createTempFile(bytes);
      
      await storageService.saveDrawing(
        imageFile: tempFile,
        authorId: currentUser.id,
        title: 'Рисунок ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
      );

      // 4. Удаляем временный файл
      await tempFile.delete();

      state = state.copyWith(operationState: const DrawingOperationSuccess());
    } catch (e) {
      state = state.copyWith(
        operationState: DrawingOperationError('Ошибка сохранения: $e'),
      );
    }
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
      backgroundImage: clearBackground ? null : (backgroundImage ?? this.backgroundImage),
      operationState: operationState ?? this.operationState,
    );
  }
}

/// Provider для DrawingController
final drawingControllerProvider = NotifierProvider<DrawingController, DrawingState>(
  () => DrawingController(),
);
