import 'package:flutter/material.dart';

class PmCircleIconButton extends StatelessWidget {
  const PmCircleIconButton({
    super.key,
    required this.icon,
    this.iconSize,
    this.iconColor,
    this.backgroundColor = Colors.white,
    this.elevation = 2,
    this.borderColor,
    this.size = defaultSize,
    this.onPressed,
  });

  static const defaultSize = 50.0;

  final IconData icon;
  final double? iconSize;
  final Color? iconColor;
  final Color backgroundColor;
  final double size;
  final double elevation;
  final Color? borderColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Card(
        shape: CircleBorder(
          side: () {
            if (borderColor != null) return BorderSide(color: borderColor!);
            if (elevation == 0) return const BorderSide(color: Colors.grey);
            return BorderSide.none;
          } (),
        ),
        color: backgroundColor,
        elevation: elevation,
        child: InkWell(
          onTap: onPressed,
          child: Icon(
            icon,
            size: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
