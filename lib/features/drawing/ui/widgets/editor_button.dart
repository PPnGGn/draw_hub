import 'package:draw_hub/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class EditorButton extends StatelessWidget {
  const EditorButton({
    required this.icon,
    required this.onTap,
    this.tooltip = '',
    this.isActive = false,
    super.key,
  });

  final Widget icon;
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
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: icon,
        ),
      ),
    );
  }
}
