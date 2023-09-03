import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'name_page.dart';

class NameGroupPage extends StatelessWidget {
  const NameGroupPage(this.group, {super.key});

  final NameGroup group;

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: group.id,
      withScrollView: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Groupe ${group.id}',
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          // Names
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Ce groupe contient ${group.names.length} noms :',
                  style: context.textTheme.titleMedium,
                ),
                AppResources.spacerMedium,
                ...group.names.map((name) {
                  return Card(
                    child: InkWell(
                      onTap: () => navigateTo(context, (context) => NamePage(name)),
                      child: Padding(
                        padding: AppResources.paddingContent,
                        child: Text(name.name),
                      ),
                    ),
                  );
                }),
              ]
            ),
          ),
        ],
      ),
    );
  }
}
