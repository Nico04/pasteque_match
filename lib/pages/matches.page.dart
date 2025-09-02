import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
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
  const _MatchesListView(this.user);

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
              child: ImplicitlyAnimatedList<String>(
                items: matches,
                areItemsTheSame: (a, b) => a == b,
                padding: AppResources.paddingPageVertical.copyWith(top: 0),
                itemBuilder: (context, animation, match, index) {
                  final group = AppService.names[match];
                  return SizeFadeTransition(
                    sizeFraction: 0.3,
                    curve: Curves.easeOut,
                    animation: animation,
                    child: VoteTile(match, group, user.votes[match]?.value, key: ValueKey(match), dismissible: false),   // Using Dismissible with AnimatedList causes issues
                  );
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
