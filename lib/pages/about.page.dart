import 'package:flutter/material.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'À propos',
      child: Column(
        children: [
          const Text('Pasteque Match'),
          const Text('TODO'),   // TODO
        ],
      ),
    );
  }
}
