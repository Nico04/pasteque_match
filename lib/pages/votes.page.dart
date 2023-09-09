import 'dart:collection';

import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'name_group.page.dart';

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
                child: ImplicitlyAnimatedList(
                  padding: AppResources.paddingPage,
                  items: SplayTreeMap.of(votes).entries.toList(),   // SplayTreeMap to sort by key (needed for consistent list edition)
                  areItemsTheSame: (a, b) => a.key == b.key,
                  itemBuilder: (context, animation, voteEntry, index) {
                    final groupId = voteEntry.key;
                    final vote = voteEntry.value;
                    final group = AppService.names[groupId];
                    return SizeFadeTransition(
                      key: ValueKey(groupId),
                      curve: Curves.easeOut,
                      sizeFraction: 0.3,
                      animation: animation,
                      child: VoteTile(groupId, group, vote),
                    );
                  },
                  separatorBuilder: (context, index) => AppResources.spacerSmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
