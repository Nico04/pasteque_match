import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'partner.page.dart';
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
      child: EventFetchBuilder<User>(
        stream: AppService.instance.userSession!.userStream,
        builder: (context, user) {
          return ValueBuilder<_Votes>(
            key: ObjectKey(user),
            valueGetter: bloc.getVotes,
            builder: (context, votes) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // User data
                  _UserDataCard(user),

                  // Stats
                  AppResources.spacerMedium,
                  _UserStatsCard(user),

                  // Matches
                  if (user.hasPartner)...[
                    AppResources.spacerMedium,
                    _MatchesCard(
                      matches: votes.matchedNames,
                    ),
                  ],

                  // Votes
                  AppResources.spacerMedium,
                  PmTileButton(
                    icon: Icons.how_to_vote,
                    label: 'Mes votes',
                    onPressed: () => navigateTo(context, (context) => const VotesPage()),
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


class ProfilePageBloc with Disposable {
  EventStream<User?> get userStream => AppService.instance.userSession!.userStream;

  _Votes getVotes() {
    final user = userStream.valueOrNull!;

    // Matches
    final matchedNames = () {
      if (AppService.instance.userSession!.hasPartner) {
        final userLikes = user.likes;
        final partner = AppService.instance.userSession!.partner!;   // TODO listen to partner changes
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
