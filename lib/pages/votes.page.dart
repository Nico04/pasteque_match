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
            items: votes.entries.toList(growable: false),
            areItemsTheSame: (a, b) => a.key == b.key,
            itemBuilder: (context, animation, voteEntry, index) {
              final groupId = voteEntry.key;
              final vote = voteEntry.value;
              return SizeFadeTransition(
                curve: Curves.easeOut,
                sizeFraction: 0.3,
                animation: animation,
                child: ValueBuilder<NameGroup?>(
                    key: ValueKey(groupId),
                    valueGetter: () => AppService.names[groupId],
                    builder: (context, group) {
                      if (group == null) {
                        return Text('Groupe $groupId introuvable');   // TODO
                      }
                      return _VoteCard(group, vote);
                    }
                ),
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
  const _VoteCard(this.group, this.vote, {super.key});

  final NameGroup group;
  final SwipeValue vote;

  @override
  Widget build(BuildContext context) {
    const backgroundLetterHeight = 200.0;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: InkWell(
        onTap: () {},   // TODO go to group page
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
                      group.name.substring(0, 1),
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
                        Text(group.name),
                        ...group.names.skip(1).take(2).map((name) {
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
                    onSelectionChanged: (value) => AppService.instance.setUserVote(group.id, value.single),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => AppService.instance.clearUserVote(group.id),
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
