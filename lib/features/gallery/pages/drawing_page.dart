import 'dart:io';
import 'dart:ui' as ui;
import 'package:draw_hub/core/providers/auth_providers.dart';
import 'package:draw_hub/core/providers/gallery_providers.dart';
import 'package:draw_hub/features/gallery/widgets/drawing_canwas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class DrawingPage extends ConsumerStatefulWidget {
  const DrawingPage({super.key});

  @override
  ConsumerState<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends ConsumerState<DrawingPage> {

   final GlobalKey _canvasKey = GlobalKey();
  // Список точек для рисования
  final List<DrawingPoint> _points = [];
  
  // Фоновое изображение (если загружено из галереи)
  ui.Image? _backgroundImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
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
            child: RepaintBoundary(
              key: _canvasKey,
              child: DrawingCanvas(
                points: _points,
                backgroundImage: _backgroundImage,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
              ),
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
  try {
    // Показываем индикатор загрузки
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // 1. Получаем текущего пользователя
    final currentUser = ref.read(authUserProvider).value;
    if (currentUser == null) {
      throw Exception('Пользователь не авторизован');
    }

    // 2. Создаем скриншот холста
    final boundary = _canvasKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    // 3. Сохраняем во временный файл
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);

    // 4. Загружаем в Firebase
    final storageService = ref.read(firebaseStorageServiceProvider);
    await storageService.saveDrawing(
      imageFile: file,
      authorId: currentUser.id, 
      title: 'Рисунок ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
    );

    // 5. Удаляем временный файл
    await file.delete();

    // Закрываем индикатор загрузки
    if (mounted) {
      Navigator.pop(context);
      
      // Показываем успешное сообщение
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Рисунок сохранен!'),
          backgroundColor: Colors.green,
        ),
      );

      // Возвращаемся в галерею
      Navigator.pop(context);
    }
  } catch (e) {
    // Закрываем индикатор загрузки
    if (mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка сохранения: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


}

// Модель точки рисования
class DrawingPoint {
  final Offset? offset;
  final Paint? paint;

  DrawingPoint({this.offset, this.paint});
}
