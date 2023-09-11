import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'name.page.dart';

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
              Card(
                child: Padding(
                  padding: AppResources.paddingContent,
                  child: Column(
                    children: [
                      Text(
                        'Mon vote',
                        style: context.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      AppResources.spacerMedium,
                      EventFetchBuilder<User>(
                        stream: AppService.instance.userSession!.userStream,
                        builder: (context, user) => VoteTile(group.id, group, user.votes[group.id], dismissible: false),
                      ),
                    ],
                  ),
                ),
              ),
              AppResources.spacerLarge,
              Text(
                'Ce groupe contient ${group.names.length} noms :',
                style: context.textTheme.titleMedium,
              ),
              Text(
                '(Trié par popularité)',
                style: context.textTheme.bodySmall,
              ),
              AppResources.spacerMedium,
              ...group.names.map<Widget>(NameTile.new).toList()..insertBetween(AppResources.spacerSmall),
            ],
          ),

          // Flag
          AppResources.spacerMedium,
          TextButton(
            onPressed: () => askConfirmation(
              context: context,
              title: 'Signaler un problème',
              caption: 'Vous avez constaté un problème avec ce groupe ?\nSignalez-le pour que nous puissions le corriger.',
              onConfirmation: () async {
                await AppService.database.reportGroupError(group.id);
                showMessage(context, 'Merci, le problème est signalé !');
              },
            ),
            child: const Text('Signaler un problème'),
          ),
        ],
      ),
    );
  }
}

class NameTile extends StatelessWidget {
  const NameTile(this.name, {super.key});

  final Name name;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => navigateTo(context, (context) => NamePage(name)),
        child: Padding(
          padding: AppResources.paddingContent,
          child: Row(
            children: [
              Text(name.name),
              AppResources.spacerTiny,
              Text(
                '(${name.stats.total})',    // TODO use better indicator
                style: context.textTheme.bodySmall,
              ),
              const Spacer(),
              GenderIcon(name.gender),
            ],
          ),
        ),
      ),
    );
  }
}
