import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/main.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/pages/profile.page.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';
import 'package:swipe_cards/swipe_cards.dart';

import 'filter_page.dart';
import 'name_group.page.dart';
import 'search.page.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with BlocProvider<SwipePage, SwipePageBloc> {
  @override
  initBloc() => SwipePageBloc();

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Pastèque  🍉  Match ️',
      action: IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => navigateTo(context, (context) => const SearchPage()),
      ),
      withScrollView: false,
      withPadding: false,
      child: FetchBuilder.basic<List<NameGroup>>(
        task: bloc.getRemainingNames,
        builder: (context, groups) {
          return Column(
            children: [
              // Filters
              Padding(
                padding: AppResources.paddingPageHorizontal,
                child: Row(
                  children: [
                    Text('TODO'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.filter_alt),
                      onPressed: () => navigateTo(context, (context) => const FilterPage()),
                    ),
                  ],
                ),
              ),

              // Stats
              Text(
                '${groups.length} groupes correspondent à vos critères',
                style: context.textTheme.bodySmall,
              ),

              // Swipe cards
              Expanded(
                child: Padding(
                  padding: AppResources.paddingPage,
                  child: () {
                    if (groups.isEmpty) return const Center(child: Text('Vous avez tout voté !'));
                    return ValueBuilder<MatchEngine>(
                      key: ObjectKey(groups),
                      valueGetter: () => _buildSwipeEngine(groups),
                      builder: (context, matchEngine) {
                        return Padding(
                          padding: AppResources.paddingPage,
                          child: SwipeCards(
                            matchEngine: matchEngine,
                            onStackFinished: () => print('onStackFinished'),    // TODO
                            itemBuilder: (context, index, distance, slideRegion) => _GroupCard(groups[index]),
                          ),
                        );
                      },
                    );
                  } (),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  MatchEngine _buildSwipeEngine(List<NameGroup> names) {
    return MatchEngine(swipeItems: names.map((name) {
      void postSwipe(SwipeValue value) async {
        // Apply vote
        debugPrint('[Swipe] ${value.name} "${name.name}"');
        final itIsAMatch = await bloc.applyVote(name.id, value);

        // It's a match !
        if (mounted && itIsAMatch) {
          showMessage(context, 'It\'s a match !');    // TODO Proper pop-up ?
        }
      }

      return SwipeItem(
        content: name,
        nopeAction: () => postSwipe(SwipeValue.dislike),
        likeAction: () => postSwipe(SwipeValue.like),
      );
    }).toList()..add(SwipeItem(
      content: null,
    )));
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard(this.group, {super.key});

  final NameGroup group;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(36))),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => navigateTo(context, (_) => NameGroupPage(group)),
        child: Padding(
          padding: AppResources.paddingPage,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: FittedBox(
                  child: Text(
                    group.name.substring(0, 1),
                    style: TextStyle(
                      fontFamily: 'Passions Conflict',
                      color: Colors.black.withOpacity(0.1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _NameGenderRow(
                      name: group.name,
                      style: context.textTheme.displayMedium?.copyWith(fontFamily: 'Merienda', color: Colors.black),
                      gender: group.names.first.gender,
                      iconSize: 40,
                    ),
                  ),
                  AppResources.spacerMedium,
                  ...group.names.skip(1).take(5).map<Widget>((name) => _NameGenderRow(
                    name: name.name,
                    style: context.textTheme.titleMedium?.copyWith(fontFamily: 'Merienda', color: Colors.black),
                    gender: name.gender
                  )).toList()..insertBetween(AppResources.spacerSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameGenderRow extends StatelessWidget {
  const _NameGenderRow({super.key, required this.name, this.style, required this.gender, this.iconSize});

  final String name;
  final TextStyle? style;
  final NameGender gender;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          name,
          style: style,
        ),
        AppResources.spacerSmall,
        GenderIcon(gender, iconSize: iconSize),
      ],
    );
  }
}


class SwipePageBloc with Disposable {
  User? get user => AppService.instance.userSession!.user;   // TODO listen to changes ?
  User? get partner => AppService.instance.userSession!.partner;   // TODO listen to changes ?

  Future<List<NameGroup>> getRemainingNames() async {
    // Init data
    final user = (await AppService.instance.userSession!.userStream.first)!;

    // Get all names
    final allNames = AppService.names;

    // Compute remaining votes
    final votedNamesId = user.votes.keys;
    final remainingNamesMap = Map.of(allNames)..removeWhere((key, value) => votedNamesId.contains(key));
    final remainingNames = remainingNamesMap.values.toList(growable: false);
    return remainingNames..shuffle();
  }

  /// Apply user's vote.
  /// Return true if it's a match.
  Future<bool> applyVote(String groupId, SwipeValue value) async {
    try {
      // Apply vote
      await AppService.instance.setUserVote(groupId, value);

      // Is it a match ?
      if (value == SwipeValue.like && partner != null) {
        final partnerVote = partner!.votes[groupId];
        if (partnerVote == SwipeValue.like) {
          return true;
        }
      }
    } catch(e, s) {
      // Report error first
      reportError(e, s);

      // Update UI
      showError(App.navigatorContext, e);
    }
    return false;
  }
}
