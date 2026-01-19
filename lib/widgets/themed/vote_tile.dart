import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/pages/name_group.page.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';

import 'letter_background.dart';
import 'pm_segmented_button.dart';

class VoteTile extends StatelessWidget {
  const VoteTile(this.groupId, this.group, this.vote, {super.key, this.editable = true, this.dismissible = false, this.clickable = true, this.leading, this.trailing});

  final String groupId;
  final NameGroup? group;
  final SwipeValue? vote;
  final bool editable;
  final bool dismissible;
  final bool clickable;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final child = Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SizedBox(
        height: 75,   // Needed to avoid Hero animation jumps
        child: InkWell(
          onTap: group == null || !clickable ? null : () => navigateTo(context, (context) => NameGroupPage(group!)),
          child: Row(
            children: [

              // Trailing
              if (leading != null)
                leading!,

              // Content
              Expanded(
                child: LetterBackground(
                  letter: groupId,
                  child: Padding(
                    padding: AppResources.paddingContent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,    // Needed to avoid Hero animation jumps
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
                          }),
                      ],
                    ),
                  ),
                ),
              ),

              // Buttons
              if (editable)
                Padding(
                  padding: AppResources.paddingContent,
                  child: PmSegmentedButton<SwipeValue>(
                    options: SwipeValue.values,
                    selected: vote,
                    iconBuilder: (value) => value.icon,
                    colorBuilder: (value) => value.color,
                    onSelectionChanged: (value) {
                      if (value == null) {
                        if (!dismissible) {
                          AppService.instance.clearUserVoteSafe(groupId);
                        }
                      } else {
                        AppService.instance.setUserVoteSafe(groupId, value);
                      }
                    },
                  ),
                ),

              // Trailing
              if (trailing != null)
                trailing!,
            ],
          ),
        ),
      ),
    );

    if (dismissible) {
      return Dismissible(
        key: ValueKey(groupId),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(FontAwesomeIcons.trashCan, color: Colors.white),
        ),
        onDismissed: (_) => AppService.instance.clearUserVoteSafe(groupId),
        child: child,
      );
    } else {
      return child;
    }
  }
}
