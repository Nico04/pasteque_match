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

import 'name_group_page.dart';

class VotesPage extends StatelessWidget {
  const VotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Mes votes',
      withPadding: false,
      withScrollView: false,
      child: EventStreamBuilder<User>(
        stream: AppService.instance.userStream,
        builder: (context, snapshot) {
          final user = snapshot.data!;
          final votes = user.votes;
          if (votes.isEmpty) {
            return const Center(child: Text('Aucun votes'));
          }
          return ImplicitlyAnimatedList(
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
                child: _VoteCard(groupId, group, vote),
              );
            },
            separatorBuilder: (context, index) => AppResources.spacerSmall,
          );
        },
      ),
    );
  }
}

class _VoteCard extends StatelessWidget {
  const _VoteCard(this.groupId, this.group, this.vote, {super.key});

  final String groupId;
  final NameGroup? group;
  final SwipeValue vote;

  @override
  Widget build(BuildContext context) {
    const backgroundLetterHeight = 200.0;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: InkWell(
        onTap: group == null ? null : () => navigateTo(context, (context) => NameGroupPage(group!)),
        child: Row(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -backgroundLetterHeight / 2, // Couldn't find a better way to center the letter vertically.
                    child: Text(
                      groupId.substring(0, 1),
                      style: TextStyle(
                        fontFamily: 'Passions Conflict',
                        fontSize: backgroundLetterHeight,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Padding(
                    padding: AppResources.paddingContent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(groupId),
                        if (group == null)
                          Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 16,
                              ),
                              Text(
                                ' Groupe introuvable',
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          )
                        else
                          ...group!.names.skip(1).take(2).map((name) {
                            return Text(
                              name.name,
                              style: context.textTheme.bodySmall,
                            );
                          }).toList(growable: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Buttons
            Padding(
              padding: AppResources.paddingContent,
              child: Row(
                children: [
                  SegmentedButton<SwipeValue>(
                    selected: {vote},
                    segments: const [
                      ButtonSegment(
                        value: SwipeValue.like,
                        icon: Icon(Icons.thumb_up),
                      ),
                      ButtonSegment(
                        value: SwipeValue.dislike,
                        icon: Icon(Icons.thumb_down),
                      ),
                    ],
                    multiSelectionEnabled: false,
                    showSelectedIcon: false,
                    onSelectionChanged: (value) => AppService.instance.setUserVote(groupId, value.single),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => AppService.instance.clearUserVote(groupId),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
