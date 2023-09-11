import 'dart:collection';

import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class VotesPage extends StatelessWidget {
  const VotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Mes votes',
      withPadding: false,
      withScrollView: false,
      child: EventStreamBuilder<User?>(   // TODO convert to EventFetchBuilder to handle loading state
        stream: AppService.instance.userSession!.userStream,
        builder: (context, snapshot) {
          final user = snapshot.data!;
          final votes = user.votes;
          if (votes.isEmpty) {
            return const Center(child: Text('Aucun votes'));
          }
          return ValueBuilder<List<MapEntry<String, SwipeValue>>>(
            key: ObjectKey(votes),
            valueGetter: () => SplayTreeMap.of(votes).entries.toList(growable: false),   // use SplayTreeMap to sort by key (needed for consistent list edition)
            builder: (context, votesEntries) {
              return Column(
                children: [
                  // Stats
                  Text(
                    'Vous avez voté pour ${votes.length} prénoms,\ndont ${user.likes.length} prénoms que vous aimez.',
                    style: context.textTheme.bodyMedium,
                  ),

                  // Content
                  AppResources.spacerSmall,
                  Expanded(
                    child: ListView.builder(
                      itemCount: votes.length,
                      itemBuilder: (context, index) {
                        final voteEntry = votesEntries[index];
                        final groupId = voteEntry.key;
                        final vote = voteEntry.value;
                        final group = AppService.names[groupId];
                        return VoteTile(groupId, group, vote);
                      },
                    ),
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
