import 'package:clipboard/clipboard.dart';
import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'partner.page.dart';
import 'votes.page.dart';
import 'about.page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Profil',
      actions: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.rightFromBracket),
          color: Colors.redAccent,
          onPressed: () => askConfirmation(
            context: context,
            title: 'Se déconnecter',
            caption: 'Êtes-vous sûr de vouloir vous déconnecter ?\nVous pourrez restaurer votre compte avec votre ID ou via votre partenaire.',
            onConfirmation: AppService.instance.logOut,
          ),
        ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.trashCan),
          color: Colors.redAccent,
          onPressed: () => askConfirmation(
            context: context,
            title: 'Supprimer mon compte',
            caption: 'Êtes-vous sûr de vouloir supprimer votre compte ?\nCette action est irréversible.',
            onConfirmation: AppService.instance.deleteUser,
          ),
        ),
      ],
      child: EventFetchBuilder<User>(
        stream: AppService.instance.userSession!.userStream,
        builder: (context, user) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // Top
              Column(
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
                    icon: FontAwesomeIcons.penToSquare,
                    label: 'Mes votes',
                    onPressed: () => navigateTo(context, (context) => const VotesPage()),
                  ),

                ],
              ),

              // Bottom
              AppResources.spacerExtraLarge,
              Column(
                children: [
                // About
                  PmTileButton(
                    icon: FontAwesomeIcons.circleQuestion,
                    label: 'À propos',
                    onPressed: () => navigateTo(context, (context) => const AboutPage()),
                  ),

                ],
              ),
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

            // Id
            Tooltip(
              message: 'Cet ID vous permet de restaurer votre compte si vous changez de téléphone.',
              child: PmButton(
                label: 'Copiez votre ID',
                isSecondary: true,
                onPressed: () => FlutterClipboard.copy(user.id).then(( _ ) => showMessage(context, 'ID copié')),
              ),
            ),

            // Partner
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
                        icon: const Icon(FontAwesomeIcons.gear),
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
