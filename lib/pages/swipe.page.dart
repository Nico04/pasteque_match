import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/main.dart';
import 'package:pasteque_match/models/filters.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

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
      child: DataStreamBuilder<FilteredNameGroups>(
        stream: bloc.filteredNameGroupsHandler.dataStream,
        builder: (context, filteredData) {
          return FetchBuilder.basic<List<NameGroup>>(
            key: ObjectKey(filteredData),
            task: () => bloc.getRemainingNames(filteredData.filtered),
            builder: (context, groups) {
              return Column(
                children: [
                  // Filters
                  Padding(
                    padding: AppResources.paddingPageHorizontal,
                    child: Row(
                      children: [
                        Expanded(
                          child: () {
                            if (filteredData.filters == null) {
                              return const Text('Aucun filtre');
                            } else {
                              return Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: filteredData.filters!.getLabels().map((label) {
                                  return Chip(
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    label: Text(
                                      label,
                                      style: context.textTheme.bodySmall,
                                    ),
                                  );
                                }).toList(growable: false),
                              );
                            }
                          } (),
                        ),
                        AppResources.spacerSmall,
                        IconButton(
                          icon: const Icon(Icons.filter_alt),
                          onPressed: () => navigateTo(context, (context) => FilterPage(bloc.filteredNameGroupsHandler)),
                        ),
                      ],
                    ),
                  ),

                  // Stats
                  AppResources.spacerSmall,
                  Text(
                    '${filteredData.filtered.length} groupes correspondent à vos critères',
                    style: context.textTheme.bodySmall,
                  ),

                  // Swipe cards
                  Expanded(
                    child: () {
                      if (groups.isEmpty) return const Center(child: Text('Vous avez tout voté !'));
                      return AppinioSwiper(
                        padding: AppResources.paddingPage,
                        cardsCount: groups.length,
                        swipeOptions: const AppinioSwipeOptions.symmetric(horizontal: true),
                        backgroundCardsCount: 2,
                        cardsSpacing: 0,    // Force cards to be behind each other
                        onSwiping: (direction) => print(direction.toString()),    // TODO
                        onSwipe: (nextCardIndex, direction) async {
                          final group = groups[nextCardIndex - 1];
                          final value = switch(direction) {
                            AppinioSwiperDirection.left => SwipeValue.dislike,
                            AppinioSwiperDirection.right => SwipeValue.like,
                            _ => throw Exception('Invalid swipe direction: $direction'),
                          };

                          // Apply vote
                          debugPrint('[Swipe] ${value.name} "${group.id}"');
                          final itsAMatch = await bloc.applyVote(group.id, value);

                          // It's a match !
                          if (mounted && itsAMatch) {
                            showMessage(context, 'It\'s a match !');    // TODO Proper pop-up ?
                          }
                        },
                        onEnd: () => print('End'),    // TODO
                        cardsBuilder: (context, index) => _GroupCard(groups[index]),
                      );
                    } (),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
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

  final filteredNameGroupsHandler = FilteredNameGroupsHandler();

  Future<List<NameGroup>> getRemainingNames(Map<String, NameGroup> names) async {
    // Init data
    final user = await AppService.instance.userSession!.userStream.first;

    // Compute remaining votes
    final votedNamesId = user.votes.keys;
    final remainingNamesMap = Map.of(names)..removeWhere((key, value) => votedNamesId.contains(key));
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

  @override
  void dispose() {
    filteredNameGroupsHandler.dispose();
    super.dispose();
  }
}
