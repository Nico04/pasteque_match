import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class NamePage extends StatelessWidget {
  const NamePage(this.name, {super.key});

  final Name name;

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: name.name,
      withScrollView: false,
      child: Center(
        child: Text(
          'TODO'
        ),
      ),
    );
  }
}
