import 'package:flutter/material.dart';

/// Диалог выбора размера кисти
class BrushSizeDialog extends StatefulWidget {
  final double initialSize;

  const BrushSizeDialog({
    required this.initialSize,
    super.key,
  });

  @override
  State<BrushSizeDialog> createState() => _BrushSizeDialogState();
}

class _BrushSizeDialogState extends State<BrushSizeDialog> {
  late double _currentSize;

  @override
  void initState() {
    super.initState();
    _currentSize = widget.initialSize;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Размер кисти'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Slider(
            value: _currentSize,
            min: 1,
            max: 20,
            label: _currentSize.round().toString(),
            onChanged: (value) => setState(() => _currentSize = value),
          ),
          Text('${_currentSize.toStringAsFixed(1)} px'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _currentSize),
          child: const Text('Применить'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
      ],
    );
  }
}
