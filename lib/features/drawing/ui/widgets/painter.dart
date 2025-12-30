
import 'package:draw_hub/features/drawing/domain/drawing_controller.dart';
import 'package:flutter/material.dart';

/// Painter для отрисовки штрихов на холсте
/// Оптимизирован для минимизации избыточных перерисовок
class Painter extends CustomPainter {
  final List<List<DrawingPoint>> strokes;
  final List<DrawingPoint> currentStroke;

  Painter({required this.strokes, required this.currentStroke});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Рисуем завершенные штрихи
    for (var stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    
    // Рисуем текущий штрих
    _drawStroke(canvas, currentStroke);

    canvas.restore(); // это ОБЯЗАТЕЛЬНО для срабатывания BlendMode.clear
  }

  /// Отрисовка одного штриха
  void _drawStroke(Canvas canvas, List<DrawingPoint> stroke) {
    for (int i = 0; i < stroke.length - 1; i++) {
      final point1 = stroke[i];
      final point2 = stroke[i + 1];
      
      final paintToDraw = point1.isEraser
          ? (Paint()
              ..color = Colors.transparent
              ..blendMode = BlendMode.clear
              ..strokeWidth = point1.paint.strokeWidth
              ..strokeCap = point1.paint.strokeCap
              ..strokeJoin = point1.paint.strokeJoin
              ..style = point1.paint.style)
          : point1.paint;
          
      canvas.drawLine(point1.offset, point2.offset, paintToDraw);
    }
  }

  @override
  bool shouldRepaint(Painter oldDelegate) {
    // Перерисовываем только если изменились штрихи или текущий штрих
    // Это предотвращает избыточные перерисовки и улучшает производительность
    return oldDelegate.strokes.length != strokes.length ||
        oldDelegate.currentStroke.length != currentStroke.length;
  }

  @override
  bool shouldRebuildSemantics(Painter oldDelegate) => false;
}
