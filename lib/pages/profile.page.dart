import 'package:fetcher/fetcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/scan_result.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';
import 'package:pasteque_match/widgets/themed/pm_qr_code_widget.dart';

import 'remove_partner.page.dart';
import 'scan.page.dart';
import 'scan_result.page.dart';
import 'votes.page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with BlocProvider<ProfilePage, ProfilePageBloc> {
  @override
  initBloc() => ProfilePageBloc();

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Profil',
      child: EventStreamBuilder<User>(
        stream: bloc.userStream,
        builder: (context, snapshot) {
          final user = snapshot.data!;
          return ValueBuilder<_Votes>(
            key: ObjectKey(user),
            valueGetter: bloc.getVotes,
            builder: (context, votes) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // Partner section
                  _PartnerCard(
                    userId: user.id,
                    partnerId: user.partnerId,
                  ),

                  // Matches
                  if (user.hasPartner)...[
                    AppResources.spacerMedium,
                    _MatchesCard(
                      matches: votes.matchedNames,
                    ),
                  ],

                  // Votes
                  AppResources.spacerMedium,
                  _VotesCard(
                    votes: votes.allVotes,
                  ),

                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.userId, this.partnerId, super.key});

  final String userId;
  final String? partnerId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppResources.paddingContent,
        child: Column(
          children: [

            // Title
            Text(
              'Votre partenaire',
              style: context.textTheme.titleLarge,
            ),

            // No partner
            AppResources.spacerLarge,
            if (partnerId == null)...[
              const Text('Vous n\'avez pas encore de partenaire'),
              AppResources.spacerMedium,
              const Text('Votre code unique :'),
              AppResources.spacerMedium,
              PmQrCodeWidget(ScanResult.buildCode(userId)),
              AppResources.spacerMedium,
              ElevatedButton(
                onPressed: () => ScanPage.goToScanOrPermissionPage(context),
                onLongPress: kReleaseMode ? null : () => navigateTo(context, (_) => ScanResultPage('PM##zvWD1Mb7fyYDBLtTKnav')),
                child: const Text('Scanner le code de votre partenaire'),
              ),
            ]

            // With partner
            else ...[
              Text(
                AppService.instance.partner!.name,
                style: context.textTheme.headlineMedium,
              ),
              AppResources.spacerMedium,
              TextButton(
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () => navigateTo(context, (_) => RemovePartnerPage(AppService.instance.partner!.name)),
                child: const Text('Supprimer votre partenaire'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchesCard extends StatelessWidget {
  const _MatchesCard({super.key, required this.matches});

  final List<Name> matches;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppResources.paddingContent,
        child: Column(
          children: [

            // Title
            Text(
              'Vos matches',
              style: context.textTheme.titleLarge,
            ),

            // Empty list
            AppResources.spacerLarge,
            if (matches.isEmpty)
              const Text('<Vide>')    // TODO

            // List
            else
              ...matches.map((match) {
                return Text(
                  match.name,
                  style: context.textTheme.bodyMedium,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _VotesCard extends StatelessWidget {
  const _VotesCard({super.key, required this.votes});

  final Map<Name, SwipeValue> votes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppResources.paddingContent,
        child: Column(
          children: [

            // Title
            Text(
              'Vos votes',
              style: context.textTheme.titleLarge,
            ),

            // Empty list
            AppResources.spacerLarge,
            FilledButton(onPressed: () => navigateTo(context, (context) => const VotesPage()), child: Text('Voir tous mes votes')),
          ],
        ),
      ),
    );
  }
}


class ProfilePageBloc with Disposable {
  EventStream<User> get userStream => AppService.instance.userStream!;

  _Votes getVotes() {
    final user = userStream.valueOrNull!;

    // Matches
    final matchedNames = () {
      if (user.hasPartner) {
        final userLikes = user.likes;
        final partner = AppService.instance.partner!;
        final partnerLikes = partner.likes;

        final matchedNameIdEntries = userLikes.where(partnerLikes.contains);
        return _buildNamesFromIds(matchedNameIdEntries);
      }
      return const <Name>[];
    } ();

    // Return result
    return _Votes(
      matchedNames: matchedNames,
      allVotes: { for (var entry in user.votes.entries) _buildNameFromId(entry.key) : entry.value },
    );
  }

  Name _buildNameFromId(String nameId) => Name(    // TODO use database
    name: nameId,
    gender: NameGender.values.first,
    stats: NameQuantityStatistics({}),    // TODO
  );

  List<Name> _buildNamesFromIds(Iterable<String> namesId) => namesId.map(_buildNameFromId).toList(growable: false);
}

class _Votes {
  const _Votes({this.matchedNames = const[], this.allVotes = const{}});

  final List<Name> matchedNames;
  final Map<Name, SwipeValue> allVotes;
}
