import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Column(
            children: [
              Text(
                'Groupe ${group.id}',
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              AppResources.spacerLarge,
              Text(
                'Ce groupe contient ${group.names.length} noms :',
                style: context.textTheme.titleMedium,
              ),
              AppResources.spacerMedium,
              ...group.names.map<Widget>((name) {
                return Card(
                  child: InkWell(
                    onTap: () => navigateTo(context, (context) => NamePage(name)),
                    child: Padding(
                      padding: AppResources.paddingContent,
                      child: Text(name.name),
                    ),
                  ),
                );
              }).toList()..insertBetween(AppResources.spacerSmall),
            ],
          ),

          // Flag
          AppResources.spacerMedium,
          FilledButton(
            onPressed: () => askConfirmation(
              context: context,
              text: 'Vous avez constaté un problème avec ce groupe ?\n\nSignalez-le pour que nous puissions le corriger.',
              onConfirmation: () async {
                await AppService.database.reportGroupError(group.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Merci, le problème est signalé !'),
                ));
              },
            ),
            child: const Text('Signaler un problème'),
          ),
        ],
      ),
    );
  }
}
