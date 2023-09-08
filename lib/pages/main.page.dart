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

import 'name_group_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with BlocProvider<MainPage, MainPageBloc> {
  @override
  initBloc() => MainPageBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            // Header
            Padding(
              padding: AppResources.paddingPageHorizontal,
              child: SizedBox(
                height: kToolbarHeight,
                child: AlignedRow(
                  center: const Text('🍉 Pastèque Match 🍉'),
                  trailing: IconButton(
                    icon: const Icon(Icons.person),
                    onPressed: () {
                      if (bloc.user != null) {
                        navigateTo(context, (_) => const ProfilePage());
                      }
                    },
                  ),
                ),
              ),
            ),

            // Swipe cards
            Expanded(
              child: FetchBuilder.basic<List<NameGroup>>(
                task: bloc.getRemainingNames,
                builder: (context, names) {
                  if (names.isEmpty) return const Center(child: Text('Vous avez tout voté !'));
                  return ValueBuilder<MatchEngine>(
                    key: ObjectKey(names),
                    valueGetter: () => _buildSwipeEngine(names),
                    builder: (context, matchEngine) {
                      return Padding(
                        padding: AppResources.paddingPage,
                        child: SwipeCards(
                          matchEngine: matchEngine,
                          onStackFinished: () => print('onStackFinished'),    // TODO
                          itemBuilder: (context, index, distance, slideRegion) => _GroupCard(names[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
                      icon: group.names.first.gender.icon,
                      iconSize: 40,
                      iconColor: group.names.first.gender.color,
                    ),
                  ),
                  AppResources.spacerMedium,
                  ...group.names.skip(1).take(5).map<Widget>((name) => _NameGenderRow(
                    name: name.name,
                    style: context.textTheme.titleMedium?.copyWith(fontFamily: 'Merienda', color: Colors.black),
                    icon: name.gender.icon,
                    iconSize: 20,
                    iconColor: name.gender.color,
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
  const _NameGenderRow({super.key, required this.name, this.style, required this.icon, required this.iconSize, this.iconColor});

  final String name;
  final TextStyle? style;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;

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
        Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      ],
    );
  }
}



class MainPageBloc with Disposable {
  User? get user => AppService.instance.user;
  User? get partner => AppService.instance.partner;

  Future<List<NameGroup>> getRemainingNames() async {
    // Init data
    final user = await AppService.instance.initData();

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
