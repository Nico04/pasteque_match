import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/pages/name_group.page.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';

class VoteTile extends StatelessWidget {
  const VoteTile(this.groupId, this.group, this.vote, {super.key});

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
              child: GroupVoteButtons(groupId, vote),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupVoteButtons extends StatelessWidget {
  const GroupVoteButtons(this.groupId, this.vote, {super.key});

  final String groupId;
  final SwipeValue? vote;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<SwipeValue>(
          selected: {if (vote != null) vote!},
          segments: const [
            ButtonSegment(
              value: SwipeValue.like,
              icon: Icon(Icons.thumb_up, color: Colors.green),
            ),
            ButtonSegment(
              value: SwipeValue.dislike,
              icon: Icon(Icons.thumb_down, color: Colors.red),
            ),
          ],
          multiSelectionEnabled: false,
          showSelectedIcon: false,
          emptySelectionAllowed: true,
          onSelectionChanged: (value) {
            if (value.isEmpty) return;
            AppService.instance.setUserVote(groupId, value.single);
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => AppService.instance.clearUserVote(groupId),
        ),
      ],
    );
  }
}
