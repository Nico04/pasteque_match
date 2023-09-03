import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class NameGroupPage extends StatelessWidget {
  const NameGroupPage(this.group, {super.key});

  final NameGroup group;

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Groupe ${group.id}',
      child: Center(
        child: Text('TODO'),
      ),
    );
  }
}
