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
      child: EventStreamBuilder<User>(
        stream: AppService.instance.userStream,
        builder: (context, snapshot) {
          final user = snapshot.data!;
          final votes = user.votes;
          if (votes.isEmpty) {
            return const Center(child: Text('Aucun votes'));
          }
          const backgroundLetterHeight = 200.0;
          return Column(
            children: votes.entries.map<Widget>((voteEntry) {
              final groupId = voteEntry.key;
              final vote = voteEntry.value;
              return ValueBuilder<NameGroup?>(
                key: ValueKey(groupId),
                valueGetter: () => AppService.names[groupId],
                builder: (context, group) {
                  if (group == null) {
                    return Text('Groupe $groupId introuvable');   // TODO
                  }
                  return Card(
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
                  );
                }
              );
            }).toList()..insertBetween(AppResources.spacerSmall),
          );
        },
      ),
    );
  }
}
