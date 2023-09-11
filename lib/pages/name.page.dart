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
      child: LetterBackground(
        letter: name.name,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Gender
            GenderIcon(
              name.gender,
              iconSize: 70,
            ),

            // Name
            AppResources.spacerLarge,
            Text(
              name.name,
              style: context.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),

            // Stats
            AppResources.spacerLarge,
            Text(
              'Ce prénom a été donné ${name.totalCount} fois en France depuis 1900',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
