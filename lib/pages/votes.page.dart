import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';

class VotesPage extends StatelessWidget {
  const VotesPage(this.votes, {super.key});

  final Map<Name, SwipeValue> votes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Votes'),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: AppResources.paddingPage,
            child: Column(
              children: [
                if (votes.isEmpty)
                  const Text('<Vide>')    // TODO

                // List
                else
                  ...votes.entries.map<Widget>((voteEntry) {
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
                                    top: -50,   // TODO Proper centering
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
                                        Text(voteEntry.key.name, style: context.textTheme.caption),
                                        Text(voteEntry.key.name, style: context.textTheme.caption),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ToggleButtons(
                              isSelected: [voteEntry.value == SwipeValue.like, voteEntry.value == SwipeValue.dislike],
                              children: [
                                Icon(Icons.thumb_up),
                                Icon(Icons.thumb_down),
                              ],
                              onPressed: (index) {}, // TODO
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline),
                              onPressed: () {}, // TODO
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList()..insertBetween(AppResources.spacerTiny),
              ],
            )
          ),
        ),
      ),
    );
  }
}
