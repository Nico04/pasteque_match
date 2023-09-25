import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'partner.page.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Matches',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => navigateTo(context, (context) => const PartnerPage()),
        ),
      ],
      withScrollView: false,
      withPadding: false,
      child: EventFetchBuilder<User>(
        stream: AppService.instance.userSession!.userStream,
        builder: (context, user) {
          if (!user.hasPartner) {
            return Padding(
              padding: AppResources.paddingPage,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Vous n\'avez pas encore de partenaire.',
                    ),
                    AppResources.spacerMedium,
                    ElevatedButton(
                      onPressed: () => navigateTo(context, (context) => const PartnerPage()),
                      child: const Text('Ajouter un⸱e partenaire'),
                    ),
                  ],
                ),
              ),
            );
          }

          return _MatchesListView(user);
        },
      ),
    );
  }
}

class _MatchesListView extends StatelessWidget {
  const _MatchesListView(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return EventFetchBuilder<User?>(
      stream: AppService.instance.userSession!.partnerStream,
      builder: (context, partner) {
        return ValueBuilder<List<String>>(
          key: ValueKey(user.hashCode ^ partner.hashCode),
          valueGetter: () => AppService.instance.getMatches(user.likes, partner?.likes ?? []),
          builder: (context, matches) {
            if (matches.isEmpty) {
              return Container(
                padding: AppResources.paddingPage,
                alignment: Alignment.center,
                child: const Text('Aucun match pour le moment'),
              );
            }
            return Column(
              children: [
                // Stats
                Text(
                  'Vous avez ${matches.length} matches',
                  style: context.textTheme.bodyMedium,
                ),

                // Content
                AppResources.spacerSmall,
                Expanded(
                  child: ListView.separated(
                    padding: AppResources.paddingPage,
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final match = matches[index];
                      final group = AppService.names[match]!;
                      return VoteTile(group.id, group, SwipeValue.like);
                    },
                    separatorBuilder: (_, __) => AppResources.spacerSmall,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
