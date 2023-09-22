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

SwipeValue swipeValueFromDirection(AppinioSwiperDirection direction) => switch(direction) {
  AppinioSwiperDirection.left => SwipeValue.dislike,
  AppinioSwiperDirection.right => SwipeValue.like,
  _ => throw UnimplementedError('Unsupported swipe direction: $direction'),
};

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> with BlocProvider<SwipePage, SwipePageBloc> {
  final _swiperKey = GlobalKey<State<AppinioSwiper>>();
  int? get _currentGroupIndex => (_swiperKey.currentState as dynamic)?.currentIndex;    // TEMP remove dynamic when package is updated. See https://github.com/appinioGmbH/flutter_packages/issues/156
  final _swipeController = AppinioSwiperController();
  final _swipeDirectionStream = DataStream<AppinioSwiperDirection?>(null);

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
      child: Stack(
        children: [
          // Background
          Positioned.fill(
            child: DataStreamBuilder<AppinioSwiperDirection?>(
              stream: _swipeDirectionStream,
              builder: (context, direction) {
                return AnimatedContainer(
                  duration: AppResources.durationAnimationMedium,
                  decoration: BoxDecoration(
                    gradient: switch(direction) {
                      AppinioSwiperDirection.left => const LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.red,
                          Colors.white,
                        ],
                        stops: [0, 0.6],
                      ),
                      AppinioSwiperDirection.right => const LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Colors.green,
                          Colors.white,
                        ],
                        stops: [0, 0.6],
                      ),
                      _ => null,
                    },
                  ),
                );
              },
            ),
          ),

          // Content
          DataStreamBuilder<FilteredNameGroups>(
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
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: filteredData.filters!.getLabels().map<Widget>((label) {
                                        return Chip(
                                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          label: Text(
                                            label,
                                            style: context.textTheme.bodySmall,
                                          ),
                                        );
                                      }).toList()..insertBetween(AppResources.spacerTiny),
                                    ),
                                  );
                                }
                              } (),
                            ),
                            AppResources.spacerSmall,
                            IconButton(
                              icon: Badge(
                                isLabelVisible: filteredData.filters != null,
                                label: Text('${filteredData.filters?.count}'),
                                child: const Icon(Icons.filter_alt),
                              ),
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
                            key: _swiperKey,
                            controller: _swipeController,
                            padding: AppResources.paddingPage,
                            cardsCount: groups.length,
                            swipeOptions: const AppinioSwipeOptions.symmetric(horizontal: true),
                            backgroundCardsCount: 2,
                            cardsSpacing: 0,    // Force cards to be behind each other
                            onSwiping: (direction) => _swipeDirectionStream.add(direction, skipSame: true, skipIfClosed: true),
                            onSwipeCancelled: () => _swipeDirectionStream.add(null, skipSame: true, skipIfClosed: true),
                            onSwipe: (nextCardIndex, direction) {
                              // Stop animation
                              _swipeDirectionStream.add(null, skipSame: true, skipIfClosed: true);

                              // Get data
                              final group = groups[nextCardIndex - 1];
                              final value = swipeValueFromDirection(direction);

                              // Apply vote
                              bloc.applyVote(group.id, value);
                            },
                            onEnd: () => print('End'),    // TODO
                            cardsBuilder: (context, index) {
                              final group = groups[index];

                              // Top card
                              if (index == _currentGroupIndex) {
                                return DataStreamBuilder<AppinioSwiperDirection?>(
                                  stream: _swipeDirectionStream,
                                  builder: (_, direction) => _GroupCard(group, key: ValueKey(index), swipeDirection: direction),
                                );
                              }

                              // Background cards
                              return _GroupCard(group, key: ValueKey(index));
                            },
                          );
                        } (),
                      ),

                      // Swipe buttons
                      /* TEMP hide for now
                      _SwipeButtons(    // TODO bug when tapping after setting filters, see https://github.com/appinioGmbH/flutter_packages/issues/157.
                        onDislikePressed: _swipeController.swipeLeft,
                        onLikePressed: _swipeController.swipeRight,
                      ),*/
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _swipeDirectionStream.close();
    super.dispose();
  }
}

class _GroupCard extends StatelessWidget {
  static const _maxOtherNames = 4;

  const _GroupCard(this.group, {super.key, this.swipeDirection});

  final NameGroup group;
  final AppinioSwiperDirection? swipeDirection;

  @override
  Widget build(BuildContext context) {
    final otherNames = group.names.skip(1);
    final overflowCount = otherNames.length - _maxOtherNames;
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
              // Background
              Positioned.fill(    // OPTI use LetterBackground widget ?
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

              // Content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main name
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _NameGenderRow(
                      name: group.name,
                      style: context.textTheme.displayMedium?.copyWith(fontFamily: 'Merienda', color: Colors.black),
                      gender: group.names.first.gender,
                      iconSize: 40,
                    ),
                  ),

                  // Other names
                  AppResources.spacerMedium,
                  ...otherNames.take(_maxOtherNames).map<Widget>((name) => _NameGenderRow(
                    name: name.name,
                    style: context.textTheme.titleMedium?.copyWith(fontFamily: 'Merienda', color: Colors.black),
                    gender: name.gender
                  )).toList()..insertBetween(AppResources.spacerSmall),

                  // Overflow indicator
                  if (otherNames.length > _maxOtherNames) ...[
                    AppResources.spacerSmall,
                    Text(
                      'et $overflowCount ${'autre'.plural(overflowCount)} ',
                      style: context.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),

              // Swipe icons
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: SwipeValue.values.map((value) {
                    return AnimatedOpacity(
                      duration: AppResources.durationAnimationMedium,
                      opacity: swipeDirection != null && value == swipeValueFromDirection(swipeDirection!) ? 1.0 : 0.2,
                      child: Icon(
                        value.icon,
                        color: value.color,
                      ),
                    );
                  }).toList(growable: false),
                ),
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

class _SwipeButtons extends StatelessWidget {
  const _SwipeButtons({super.key, required this.onDislikePressed, required this.onLikePressed});

  final VoidCallback onDislikePressed;
  final VoidCallback onLikePressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppResources.paddingPage.copyWith(top: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PmCircleIconButton(
            icon: SwipeValue.dislike.icon,
            iconColor: SwipeValue.dislike.color,
            onPressed: onDislikePressed,
          ),
          PmCircleIconButton(
            icon: SwipeValue.like.icon,
            iconColor: SwipeValue.like.color,
            onPressed: onLikePressed,
          ),
        ],
      ),
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
    debugPrint('[Swipe] ${value.name} "$groupId"');
    try {
      // Apply vote
      return AppService.instance.setUserVote(groupId, value);
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
