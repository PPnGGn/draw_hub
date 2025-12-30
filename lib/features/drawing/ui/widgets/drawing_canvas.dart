// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';

// class DrawingCanvas extends StatelessWidget {
//   final List<DrawingPoint> points;
//   final ui.Image? backgroundImage;
//   final Function(DragStartDetails) onPanStart;
//   final Function(DragUpdateDetails) onPanUpdate;
//   final Function(DragEndDetails) onPanEnd;

//   const DrawingCanvas({
//     super.key,
//     required this.points,
//     required this.backgroundImage,
//     required this.onPanStart,
//     required this.onPanUpdate,
//     required this.onPanEnd,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanStart: onPanStart,
//       onPanUpdate: onPanUpdate,
//       onPanEnd: onPanEnd,
//       child: Container(
//         color: Colors.white,
//         child: CustomPaint(
//           painter: DrawingPainter(
//             points: points,
//             backgroundImage: backgroundImage,
//           ),
//           child: Container(),
//         ),
//       ),
//     );
//   }
// }

// class DrawingPainter extends CustomPainter {
//   final List<DrawingPoint> points;
//   final ui.Image? backgroundImage;

//   DrawingPainter({
//     required this.points,
//     this.backgroundImage,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Рисуем фоновое изображение (если есть)
//     if (backgroundImage != null) {
//       // Масштабируем изображение под размер холста
//       final src = Rect.fromLTWH(
//         0,
//         0,
//         backgroundImage!.width.toDouble(),
//         backgroundImage!.height.toDouble(),
//       );
//       final dst = Rect.fromLTWH(0, 0, size.width, size.height);
//       canvas.drawImageRect(backgroundImage!, src, dst, Paint());
//     }

//     // Рисуем линии
//     for (int i = 0; i < points.length - 1; i++) {
//       if (points[i].offset != null && points[i + 1].offset != null) {
//         canvas.drawLine(
//           points[i].offset!,
//           points[i + 1].offset!,
//           points[i].paint!,
//         );
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant DrawingPainter oldDelegate) {
//     return oldDelegate.points != points ||
//         oldDelegate.backgroundImage != backgroundImage;
//   }
// }
