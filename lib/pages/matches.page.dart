import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/models/filters.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/services/storage_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'partner.page.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Matches',
      actions: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.gear),
          onPressed: () => navigateTo(context, (context) => const PartnerPage()),
        ),
      ],
      withScrollView: false,
      withPadding: false,
      child: EventFetchBuilder<User>(
        stream: AppService.instance.userSession!.userStream,
        config: const FetcherConfig(
          fadeDuration: Duration.zero,    // Disable fade to prevent child tree to lose state on user change (like vote delete)
        ),
        builder: (context, user) {
          if (!user.hasPartner) {
            return Padding(
              padding: AppResources.paddingPage,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Vous n\'avez pas encore de partenaire.',
                    ),
                    AppResources.spacerMedium,
                    PmButton(
                      label: 'Ajouter un⸱e partenaire',
                      onPressed: () => navigateTo(context, (context) => const PartnerPage()),
                    ),
                  ],
                ),
              ),
            );
          }

          return EventFetchBuilder<User?>(
            stream: AppService.instance.userSession!.partnerStream,
            config: const FetcherConfig(
              fadeDuration: Duration.zero,    // Disable fade to prevent child tree to lose state on partner change
            ),
            builder: (context, partner) {
              return ValueBuilder(
                value: (user.likes, partner?.likes),
                valueBuilder: (data) {
                  final (userLikes, partnerLikes) = data;
                  return AppService.instance.getMatches(userLikes, partnerLikes ?? []);
                },
                builder: (context, matches) {
                  return _MatchesListView(user, matches);
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MatchesListView extends StatefulWidget {
  const _MatchesListView(this.user, this.matches);

  final User user;
  final List<String> matches;

  @override
  State<_MatchesListView> createState() => _MatchesListViewState();
}

class _MatchesListViewState extends State<_MatchesListView> with BlocProvider<_MatchesListView, _MatchesListViewBloc> {
  @override
  initBloc() => _MatchesListViewBloc();

  @override
  Widget build(BuildContext context) {
    return DataStreamBuilder(
      stream: bloc.filters,
      builder: (context, filters) {
        return FilteredView<String, _MatchesPageFilters>(
          list: widget.matches,
          filterValue: filters,
          ignoreWhen: bloc.ignoreFilterWhen,
          filter: (name, filter) => bloc.applyFilter(name, filter, widget.user),
          builder: (context, filteredMatches) {
            final filteredMatchesList = filteredMatches.toList(growable: false);
            if (filteredMatchesList.isEmpty) {
              return Container(
                padding: AppResources.paddingPage,
                alignment: Alignment.center,
                child: const Text('Aucun match pour le moment'),
              );
            }
            return Column(
              children: [
                // Filters
                Padding(
                  padding: AppResources.paddingContentHorizontal,
                  child: Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Gender
                            PmSegmentedButton(
                              options: GroupGenderFilter.values,
                              selected: filters.gender,
                              iconBuilder: (value) => value.icon,
                              onSelectionChanged: bloc.updateGenderFilter,
                            ),

                            // Visibility toggle
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: Icon(
                                  filters.showHidden
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye,
                                ),
                                tooltip: filters.showHidden
                                    ? 'Masquer mes matches cachés'
                                    : 'Afficher mes matches cachés',
                                onPressed: () => bloc.updateShowHiddenFilter(!filters.showHidden),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats
                AppResources.spacerSmall,
                Text(
                  'Affichage de ${filteredMatchesList.length} matches sur ${widget.matches.length}',   // TODO plural
                  style: context.textTheme.bodySmall,
                ),

                // Content
                AppResources.spacerSmall,
                Expanded(
                  child: ImplicitlyAnimatedReorderableList<String>(
                    padding: AppResources.paddingPageVertical.copyWith(top: 0),
                    items: filteredMatchesList,
                    areItemsTheSame: (a, b) => a == b,
                    onReorderFinished: bloc.onReorderFinished,
                    itemBuilder: (context, animation, match, index) {
                      final group = AppService.names[match];
                      return Reorderable(
                        key: ValueKey(match),
                        child: SizeFadeTransition(
                          sizeFraction: 0.3,
                          curve: Curves.easeOut,
                          animation: animation,
                          child: VoteTile(match, group, widget.user.votes[match]?.value,
                            editable: false,
                            hidable: true,
                            leading: Padding(
                              padding: AppResources.paddingContent,
                              child: Text(
                                '#${index + 1}',
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            trailing: const Handle(
                              delay: Duration.zero,
                              child: Padding(
                                padding: AppResources.paddingContent,
                                child: Column(    // Allow handle to take full height
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.gripVertical,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MatchesListViewBloc with Disposable {
  final filters = DataStream<_MatchesPageFilters>(_MatchesPageFilters(gender: StorageService.readMatchesFilters()));

  bool ignoreFilterWhen(_MatchesPageFilters filterValue) => filterValue.isEmpty;
  bool applyFilter(String name, _MatchesPageFilters filter, UserData user) {
    final group = AppService.names[name];
    if (group == null) return false;
    return filter.gender?.match(group) != false && (filter.showHidden || !user.isNameHidden(name));
  }

  void updateGenderFilter(GroupGenderFilter? value) {
    filters.add(filters.value.copyWithGender(value));
    StorageService.saveMatchesFilters(value);
  }

  void updateShowHiddenFilter(bool value) => filters.add(filters.value.copyWithShowHidden(value));

  void onReorderFinished(String item, int from, int to, List<String> newItems) =>
      AppService.instance.setNameOrderIndexes(newItems, to);

  @override
  void dispose() {
    filters.close();
    super.dispose();
  }
}

class _MatchesPageFilters {
  const _MatchesPageFilters({
    this.gender,
    this.showHidden = false,
  });

  final GroupGenderFilter? gender;
  final bool showHidden;

  bool get isEmpty => gender == null && showHidden;

  _MatchesPageFilters copyWithGender(GroupGenderFilter? gender) => _MatchesPageFilters(
    gender: gender,
    showHidden: showHidden,
  );

  _MatchesPageFilters copyWithShowHidden(bool showHidden) => _MatchesPageFilters(
    gender: gender,
    showHidden: showHidden,
  );
}
