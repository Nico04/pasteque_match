import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class VotesPage extends StatelessWidget {
  const VotesPage(this.votes, {super.key});

  final Map<Name, SwipeValue> votes;

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Mes votes',
      child: () {
        if (votes.isEmpty) {
          return const Center(child: Text('<Vide>'));
        }
        return Column(
          children: votes.entries.map<Widget>((voteEntry) {
            return Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: -100, // TODO Proper centering
                            bottom: 0,
                            child: Center(
                              child: Text(
                                voteEntry.key.name.substring(0, 1),
                                style: TextStyle(
                                  fontFamily: 'Passions Conflict',
                                  fontSize: 200,
                                  color: Colors.black.withOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: AppResources.paddingContent,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(voteEntry.key.name),
                                Text(voteEntry.key.name, style: context.textTheme.caption), // TODO secondary names
                                Text(voteEntry.key.name, style: context.textTheme.caption), // TODO secondary names
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SegmentedButton<SwipeValue>(
                      selected: {voteEntry.value},
                      segments: [
                        ButtonSegment(
                          value: SwipeValue.like,
                          icon: Icon(Icons.thumb_up),
                        ),
                        ButtonSegment(
                          value: SwipeValue.dislike,
                          icon: Icon(Icons.thumb_down),
                        ),
                      ],
                      showSelectedIcon: false,
                      onSelectionChanged: (value) {}, // TODO
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: () {}, // TODO
                    ),
                  ],
                ),
              ),
            );
          }).toList()
            ..insertBetween(AppResources.spacerTiny),
        );
      }(),
    );
  }
}
