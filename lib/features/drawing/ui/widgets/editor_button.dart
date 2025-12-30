import 'package:flutter/material.dart';

class EditorButton extends StatelessWidget {
  const EditorButton({
    required this.icon,
    required this.onTap,
    this.tooltip = '',
    this.isActive = false,
    super.key,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 38,
          width: 38,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}
