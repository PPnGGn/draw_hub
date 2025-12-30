import 'dart:typed_data';

import 'package:draw_hub/features/drawing/domain/drawing_controller.dart';
import 'package:draw_hub/features/drawing/ui/widgets/brush_size_dialog.dart';
import 'package:draw_hub/features/drawing/ui/widgets/color_picker.dart';
import 'package:draw_hub/features/drawing/ui/widgets/editor_button.dart';
import 'package:draw_hub/features/drawing/ui/widgets/painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Страница редактора холста (Presentation Layer)
/// Отвечает только за отображение UI и делегирование действий контроллеру
class EditorPage extends ConsumerStatefulWidget {
  final Uint8List? backgroundImage;
  const EditorPage({this.backgroundImage, super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Инициализация контроллера с фоновым изображением
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(drawingControllerProvider.notifier).initializeEditor(backgroundImage: widget.backgroundImage);
    });
  }

  /// Обработчик сохранения холста
  void _onSavePressed() {
    ref.read(drawingControllerProvider.notifier).saveDrawing(_repaintBoundaryKey);
  }

  /// Обработчик выбора размера кисти
  Future<void> _onBrushPressed() async {
    final currentWidth = ref.read(drawingControllerProvider).selectedWidth;
    final newWidth = await showDialog<double>(
      context: context,
      builder: (context) => BrushSizeDialog(initialSize: currentWidth),
    );
    
    if (newWidth != null && mounted) {
      ref.read(drawingControllerProvider.notifier).changeBrushWidth(newWidth);
    }
  }

  /// Обработчик выбора цвета
  void _onColorPressed() {
    final currentColor = ref.read(drawingControllerProvider).selectedColor;
    showDialog(
      context: context,
      builder: (_) => ColorPicker(
        selectedColor: currentColor,
        onPick: (color) {
          if (mounted) {
            ref.read(drawingControllerProvider.notifier).changeColor(color);
          }
        },
      ),
    );
  }

  /// Обработчик переключения ластика
  void _onEraserPressed() {
    ref.read(drawingControllerProvider.notifier).toggleEraser();
  }

  /// Обработчик очистки холста
  void _onClearPressed() {
    ref.read(drawingControllerProvider.notifier).clearCanvas();
  }

  /// Обработчик импорта изображения
  Future<void> _onImportImage() async {
    await ref.read(drawingControllerProvider.notifier).importImage();
  }

  @override
  Widget build(BuildContext context) {
    final drawingState = ref.watch(drawingControllerProvider);

    // Отображение уведомлений об ошибках и успехе
    ref.listen(drawingControllerProvider, (previous, next) {
      // Проверяем, что состояние операции изменилось
      if (next.operationState is DrawingOperationError) {
        final errorState = next.operationState as DrawingOperationError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${errorState.message}')),
        );
        // Сбрасываем состояние ошибки
        Future.microtask(() {
          ref.read(drawingControllerProvider.notifier).resetOperationState();
        });
      }
      
      // Проверяем успешное сохранение
      if (next.operationState is DrawingOperationSuccess && 
          previous?.operationState is! DrawingOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Холст успешно сохранён!')),
        );
        // Сбрасываем состояние успеха
        Future.microtask(() {
          ref.read(drawingControllerProvider.notifier).resetOperationState();
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _onSavePressed,
            tooltip: 'Сохранить',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _onClearPressed,
            tooltip: 'Очистить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21),
        child: Column(
          children: [
            // Панель инструментов
            SizedBox(
              height: 86,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  EditorButton(
                    icon: Icons.download,
                    onTap: _onSavePressed,
                    tooltip: 'Сохранить',
                  ),
                  const SizedBox(width: 12),
                  EditorButton(
                    icon: Icons.image,
                    onTap: _onImportImage,
                    tooltip: 'Импорт из галереи',
                  ),
                  const SizedBox(width: 12),
                  EditorButton(
                    icon: Icons.brush,
                    onTap: _onBrushPressed,
                    tooltip: 'Размер кисти',
                  ),
                  const SizedBox(width: 12),
                  EditorButton(
                    icon: Icons.color_lens,
                    onTap: _onColorPressed,
                    tooltip: 'Цвет',
                  ),
                  const SizedBox(width: 12),
                  EditorButton(
                    icon: Icons.delete_outline,
                    onTap: _onEraserPressed,
                    tooltip: drawingState.isEraserMode ? 'Выключить ластик' : 'Ластик',
                    isActive: drawingState.isEraserMode,
                  ),
                ],
              ),
            ),
            // Индикатор загрузки
            if (drawingState.operationState is DrawingOperationLoading)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: LinearProgressIndicator(),
              ),
            // Холст для рисования
            Expanded(
              child: GestureDetector(
                onPanDown: (details) {
                  ref.read(drawingControllerProvider.notifier).startStroke(details.localPosition);
                },
                onPanUpdate: (details) {
                  ref.read(drawingControllerProvider.notifier).updateStroke(details.localPosition);
                },
                onPanEnd: (details) {
                  ref.read(drawingControllerProvider.notifier).endStroke();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Фоновое изображение
                        if (drawingState.backgroundImage != null)
                          Image.memory(
                            drawingState.backgroundImage!,
                            fit: BoxFit.cover,
                          ),
                        // Слой рисования
                        CustomPaint(
                          painter: Painter(
                            strokes: drawingState.strokes,
                            currentStroke: drawingState.currentStroke,
                          ),
                          child: Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
