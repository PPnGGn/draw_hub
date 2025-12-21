import 'package:draw_hub/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
  });

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 1],
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: FilledButton(
        onPressed: onPressed,

        style: Theme.of(context).filledButtonTheme.style?.copyWith(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
