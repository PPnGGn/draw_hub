import 'dart:typed_data';

import 'package:draw_hub/core/services/notification_service.dart';
import 'package:draw_hub/features/drawing/domain/drawing_controller.dart';
import 'package:draw_hub/features/drawing/ui/widgets/brush_size_dialog.dart';
import 'package:draw_hub/features/drawing/ui/widgets/color_picker.dart';
import 'package:draw_hub/features/drawing/ui/widgets/editor_button.dart';
import 'package:draw_hub/features/drawing/ui/widgets/painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class EditorPage extends ConsumerStatefulWidget {
  final Uint8List? backgroundImage;
  final bool closeOnSave;
  const EditorPage({this.backgroundImage, this.closeOnSave = false, super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(drawingControllerProvider.notifier)
          .initializeEditor(backgroundImage: widget.backgroundImage);
    });
  }

  /// Обработчик сохранения холста
  void _onSavePressed() {
    ref
        .read(drawingControllerProvider.notifier)
        .saveDrawing(_repaintBoundaryKey);
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

  /// Обработчик экспорта изображения
  Future<void> _onExportPressed() async {
    await ref
        .read(drawingControllerProvider.notifier)
        .exportDrawing(_repaintBoundaryKey);
  }

  @override
  Widget build(BuildContext context) {
    final drawingState = ref.watch(drawingControllerProvider);

    ref.listen(drawingControllerProvider, (previous, next) {
      if (next.operationState is DrawingOperationError) {
        final errorState = next.operationState as DrawingOperationError;

        // Show error notification
        NotificationService().showErrorNotification(errorState.message);

        // Reset error state
        Future.microtask(() {
          ref.read(drawingControllerProvider.notifier).resetOperationState();
        });
      }
      // Check for successful save
      if (next.operationState is DrawingOperationSuccess &&
          previous?.operationState is! DrawingOperationSuccess) {
        final successState = next.operationState as DrawingOperationSuccess;
        // Show success notification
        NotificationService().showSuccessNotification();

        // Reset success state
        Future.microtask(() {
          ref.read(drawingControllerProvider.notifier).resetOperationState();
        });

        if (successState.operation == 'save') {
          Future.microtask(() {
            if (context.mounted) {
              context.pop();
            }
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактор'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onSavePressed,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 21),
        child: Column(
          children: [
            SizedBox(
              height: 86,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  EditorButton(
                    icon: const Icon(Icons.share),
                    onTap: _onExportPressed,
                    tooltip: 'Экспорт',
                  ),
                  const SizedBox(width: 12),
                  EditorButton(
                    icon: SvgPicture.asset('assets/svg/import.svg'),
                    onTap: _onImportImage,
                    tooltip: 'Импорт из галереи',
                  ),
                  const SizedBox(width: 12),
                  EditorButton(
                    icon: const Icon(Icons.brush),
                    onTap: _onBrushPressed,
                    tooltip: 'Размер кисти',
                  ),
                  const SizedBox(width: 12),
                  EditorButton(
                    icon: SvgPicture.asset('assets/svg/palette.svg'),
                    onTap: _onColorPressed,
                    tooltip: 'Цвет',
                  ),
                  const SizedBox(width: 12),
                  EditorButton(
                    icon: SvgPicture.asset('assets/svg/eraser.svg'),
                    onTap: _onEraserPressed,
                    tooltip: drawingState.isEraserMode
                        ? 'Выключить ластик'
                        : 'Ластик',
                    isActive: drawingState.isEraserMode,
                  ),
                  const SizedBox(width: 12),
                  EditorButton(
                    icon: Icon(Icons.clear_all),
                    onTap: _onClearPressed,
                    tooltip: 'Очистить',
                  ),
                ],
              ),
            ),
            if (drawingState.operationState is DrawingOperationLoading)
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: LinearProgressIndicator(),
              ),
            // Холст для рисования
            Expanded(
              child: GestureDetector(
                onPanDown: (details) {
                  ref
                      .read(drawingControllerProvider.notifier)
                      .startStroke(details.localPosition);
                },
                onPanUpdate: (details) {
                  ref
                      .read(drawingControllerProvider.notifier)
                      .updateStroke(details.localPosition);
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
                        drawingState.backgroundImage != null
                            ? Image.memory(
                                drawingState.backgroundImage!,
                                fit: BoxFit.cover,
                              )
                            : Container(color: Colors.white),
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
