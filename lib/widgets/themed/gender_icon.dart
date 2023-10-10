import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';

class GenderIcon extends StatelessWidget {
  const GenderIcon(this.gender, {super.key, double? iconSize}) : iconSize = iconSize ?? 16;

  final NameGender gender;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Icon(
      gender.icon,
      size: iconSize,
      color: gender.color,
    );
  }
}
