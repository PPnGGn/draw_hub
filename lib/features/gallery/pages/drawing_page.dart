import 'dart:ui' as ui;
import 'package:draw_hub/core/providers/gallery_providers.dart';
import 'package:draw_hub/features/gallery/widgets/drawing_canwas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class DrawingPage extends ConsumerStatefulWidget {
  const DrawingPage({super.key});

  @override
  ConsumerState<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends ConsumerState<DrawingPage> {
  // Список точек для рисования
  final List<DrawingPoint> _points = [];
  
  // Фоновое изображение (если загружено из галереи)
  ui.Image? _backgroundImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Редактор'),
        actions: [
          // Кнопка загрузки изображения из галереи
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImageFromGallery,
            tooltip: 'Загрузить из галереи',
          ),
          // Кнопка сохранения
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDrawing,
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Column(
        children: [
          // Панель инструментов
          _buildToolbar(),
          
          // Холст для рисования
          Expanded(
            child: DrawingCanvas(
              points: _points,
              backgroundImage: _backgroundImage,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
            ),
          ),
        ],
      ),
    );
  }

  // Панель инструментов
  Widget _buildToolbar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Кнопка очистки холста
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearCanvas,
            tooltip: 'Очистить',
          ),
          
          // Кнопка отмены последнего действия
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _points.isNotEmpty ? _undo : null,
            tooltip: 'Отменить',
          ),
          
          // TODO: Добавим выбор цвета, размера кисти и т.д.
        ],
      ),
    );
  }

  // Начало рисования
  void _onPanStart(DragStartDetails details) {
    setState(() {
      _points.add(
        DrawingPoint(
          offset: details.localPosition,
          paint: Paint()
            ..color = Colors.black
            ..strokeWidth = 3.0
            ..strokeCap = StrokeCap.round,
        ),
      );
    });
  }

  // Процесс рисования
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(
        DrawingPoint(
          offset: details.localPosition,
          paint: Paint()
            ..color = Colors.black
            ..strokeWidth = 3.0
            ..strokeCap = StrokeCap.round,
        ),
      );
    });
  }

  // Конец рисования (разрыв линии)
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _points.add(DrawingPoint(offset: null, paint: null));
    });
  }

  // Очистка холста
  void _clearCanvas() {
    setState(() {
      _points.clear();
      _backgroundImage = null;
    });
  }

  // Отмена последнего действия
  void _undo() {
    setState(() {
      if (_points.isNotEmpty) {
        // Удаляем точки до последнего разрыва (null)
        int lastNullIndex = _points.lastIndexWhere((point) => point.offset == null);
        
        if (lastNullIndex != -1 && lastNullIndex > 0) {
          _points.removeRange(lastNullIndex, _points.length);
        } else {
          _points.clear();
        }
      }
    });
  }

  // Загрузка изображения из галереи
Future<void> _pickImageFromGallery() async {
  try {
    final imageService = ref.read(imageServiceProvider);
    final imageFile = await imageService.pickImageFromGallery();

    if (imageFile == null) return;

    // Загружаем изображение как ui.Image
    final bytes = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    setState(() {
      _backgroundImage = frame.image;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Изображение загружено')),
      );
    }
  } catch (e) {
    if (mounted) {
      // Проверяем тип ошибки
      if (e.toString().contains('доступа')) {
        // Показываем диалог с предложением открыть настройки
        _showPermissionDeniedDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка загрузки: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Диалог при отказе в разрешении
Future<void> _showPermissionDeniedDialog() async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Нет доступа к галерее'),
      content: const Text(
        'Для загрузки изображений необходимо разрешение. '
        'Откройте настройки и предоставьте доступ к галерее.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await openAppSettings();
          },
          child: const Text('Настройки'),
        ),
      ],
    ),
  );
}


  // Сохранение рисунка (пока заглушка)
  Future<void> _saveDrawing() async {
    // TODO: Следующий шаг - сохранение в Firebase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Сохранение пока не реализовано')),
    );
  }
}

// Модель точки рисования
class DrawingPoint {
  final Offset? offset;
  final Paint? paint;

  DrawingPoint({this.offset, this.paint});
}
