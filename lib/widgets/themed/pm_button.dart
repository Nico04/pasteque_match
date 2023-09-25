import 'package:flutter/material.dart';

class PmButton extends StatelessWidget {
  const PmButton({super.key, required this.label, this.isSecondary = false, this.onPressed});
  PmButton.fromData(ButtonData data, {super.key, this.isSecondary = false}) : label = data.label, onPressed = data.onPressed;

  final String label;
  final bool isSecondary;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isSecondary) {
      return TextButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }
    return FilledButton(
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
