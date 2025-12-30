import 'package:flutter/material.dart';
// TODO: диалог с выбором цветов, надо будет сделать красивый вариант из фигмы
class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onPick;

  const ColorPicker({
    required this.selectedColor,
    required this.onPick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.black,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];

    return AlertDialog(
      title: const Text('Выберите цвет'),
      content: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                onPick(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: selectedColor == color ? 4 : 2,
                    color: selectedColor == color ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Закрыть'),
        ),
      ],
    );
  }
}
