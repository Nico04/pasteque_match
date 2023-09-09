import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'partner.page.dart';
import 'votes.page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Profil',
      child: EventFetchBuilder<User>(
        stream: AppService.instance.userSession!.userStream,
        builder: (context, user) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // User data
              _UserDataCard(user),

              // Stats
              AppResources.spacerMedium,
              _UserStatsCard(user),

              // Votes
              AppResources.spacerMedium,
              PmTileButton(
                icon: Icons.how_to_vote,
                label: 'Mes votes',
                onPressed: () => navigateTo(context, (context) => const VotesPage()),
              ),

              // Delete account
              AppResources.spacerLarge,
              TextButton(
                onPressed: () => askConfirmation(
                  context: context,
                  title: 'Supprimer mon compte',
                  caption: 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
                  onConfirmation: AppService.instance.deleteUser,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
                child: Text('Supprimer mon compte'),
              )

            ],
          );
        },
      ),
    );
  }
}

class _UserDataCard extends StatelessWidget {
  const _UserDataCard(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppResources.paddingContent,
        child: Column(
          children: [

            // Title
            Text(
              user.name,
              style: context.textTheme.titleLarge,
            ),

            // Partner
            AppResources.spacerLarge,
            if (user.hasPartner)
              EventFetchBuilder<User?>(
                stream: AppService.instance.userSession!.partnerStream,
                builder: (context, partner) {
                 return Row(
                   children: [
                     Expanded(
                       child: Text('Partenaire : ${partner?.name ?? '<Inconnu>'}'),
                     ),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () => navigateTo(context, (context) => const PartnerPage()),
                      ),
                   ],
                 );
               },
             )
            else
              const Text('Vous n\'avez pas encore de partenaire'),

          ],
        ),
      ),
    );
  }
}

class _UserStatsCard extends StatelessWidget {
  const _UserStatsCard(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppResources.paddingContent,
        child: Column(
          children: [

            // Title
            Text(
              'Statistiques',
              style: context.textTheme.titleLarge,
            ),

            // Content
            AppResources.spacerLarge,
            Text('Nombre de votes : ${user.votes.length}'),
            AppResources.spacerSmall,
            Text('Nombre de likes : ${user.likes.length}'),

          ],
        ),
      ),
    );
  }
}
