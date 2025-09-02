import 'package:flutter/material.dart';

class PmButton extends StatelessWidget {
  const PmButton({super.key, required this.label, this.isSecondary = false, this.color, this.onPressed});
  PmButton.fromData(ButtonData data, {super.key, this.isSecondary = false, this.color}) : label = data.label, onPressed = data.onPressed;

  final String label;
  final bool isSecondary;
  final Color? color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = color == null ? null : ButtonStyle(foregroundColor: WidgetStateProperty.all(color));
    if (isSecondary) {
      return TextButton(
        style: style,
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return FilledButton(
      style: style,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class ButtonData {
  const ButtonData({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;
}
