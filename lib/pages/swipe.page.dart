import 'dart:math' as math;

import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/filters.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'filter.page.dart';
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
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => navigateTo(context, (context) => const SearchPage()),
        ),
      ],
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
                          if (groups.isEmpty) return const Center(child: Text('Aucun groupe non-voté ne correspond aux filtres actuels'));

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Caption when no cards left
                              const Positioned(
                                child: Padding(
                                  padding: AppResources.paddingPage,
                                  child: Text(
                                    'Vous avez tout voté !\nChangez les filtres pour continuer.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),

                              // Cards
                              EventStreamBuilder<User?>(
                                stream: AppService.instance.userSession!.partnerStream,
                                builder: (context, snapshot) {
                                  final partner = snapshot.data;
                                  final partnerLikes = partner?.likes.toList(growable: false) ?? [];
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
                                      AppService.instance.setUserVoteSafe(group.id, value);
                                    },
                                    cardsBuilder: (context, index) {
                                      final group = groups[index];
                                      final doesPartnerLike = partnerLikes.contains(group.id);

                                      Widget buildGroupCard([AppinioSwiperDirection? swipeDirection]) {
                                        return _GroupCard(group, key: ValueKey(index), partnerLikesName: doesPartnerLike ? partner!.name : null, swipeDirection: swipeDirection);
                                      }

                                      // Top card
                                      if (index == _currentGroupIndex) {
                                        return DataStreamBuilder<AppinioSwiperDirection?>(
                                          stream: _swipeDirectionStream,
                                          builder: (_, direction) => buildGroupCard(direction),
                                        );
                                      }

                                      // Background cards
                                      return buildGroupCard();
                                    },
                                  );
                                },
                              )
                            ],
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

  const _GroupCard(this.group, {super.key, this.swipeDirection, this.partnerLikesName});

  final NameGroup group;
  final AppinioSwiperDirection? swipeDirection;
  final String? partnerLikesName;

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
                child: FittedBox(  // Auto size if too long
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

              // Partner like
              if (partnerLikesName != null)
                Positioned(
                  top: 0,
                  child: Text(
                    '🍉 $partnerLikesName aime 🍉',
                    style: context.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
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
  final filteredNameGroupsHandler = FilteredNameGroupsHandler();

  Future<List<NameGroup>> getRemainingNames(Map<String, NameGroup> filteredNames) async {
    // Init data
    final user = await AppService.instance.userSession!.userStream.first;
    final partner = user.hasPartner ? await AppService.instance.userSession!.partnerStream.first : null;

    // Compute remaining votes
    final votedNamesId = user.votes.keys;
    final remainingNamesMap = Map.of(filteredNames)..removeAll(votedNamesId);
    final remainingNames = remainingNamesMap.values.toList();
    remainingNames.shuffle();

    // Insert partner likes
    if (partner != null) {
      final partnerLikes = partner.likes.toList();

      // Remove user votes
      partnerLikes.removeAll(votedNamesId);

      // Remove them from the remaining names (will be added just after), to avoid duplicates
      remainingNames.removeWhere((group) => partnerLikes.contains(group.id));

      // Shuffle
      partnerLikes.shuffle();

      // Insert partner likes randomly on top of the list (event if not respecting filters)
      final random = math.Random();
      int lastInsertIndex = 0;
      for (final partnerLike in partnerLikes) {
        final insertIndex = lastInsertIndex + random.nextIntInRange(2, 8);
        if (insertIndex >= remainingNames.length) break;
        remainingNames.insert(insertIndex, AppService.names[partnerLike]!);
        lastInsertIndex = insertIndex;
      }
    }

    return remainingNames;
  }

  @override
  void dispose() {
    filteredNameGroupsHandler.dispose();
    super.dispose();
  }
}
