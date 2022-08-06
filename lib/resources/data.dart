import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';

const _nameGenderData = {
  NameGender.male: _NameGenderData(Icons.male, Colors.blue),
  NameGender.female: _NameGenderData(Icons.female, Colors.pink),
  NameGender.unisex: _NameGenderData(Icons.transgender, Colors.blueGrey),
};

extension ExtendedNameGender on NameGender {
  IconData get icon => _nameGenderData[this]!.icon;
  Color get color => _nameGenderData[this]!.color;
}

class _NameGenderData {
  const _NameGenderData(this.icon, this.color);

  final IconData icon;
  final Color color;
}
