import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
          icon: const Icon(FontAwesomeIcons.gear),
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
                    PmButton(
                      label: 'Ajouter un⸱e partenaire',
                      onPressed: () => navigateTo(context, (context) => const PartnerPage()),
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
        // Build matches list at build time. Using ValueBuilder makes widget loose scroll state when data changes.
        final matches = AppService.instance.getMatches(user.likes, partner?.likes ?? []);

        // Build widget
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
                  final group = AppService.names[match];
                  return VoteTile(match, group, SwipeValue.like);
                },
                separatorBuilder: (_, __) => AppResources.spacerSmall,
              ),
            ),
          ],
        );
      },
    );
  }
}
