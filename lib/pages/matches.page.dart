import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/models/filters.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
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
    return DataStreamBuilder<GroupGenderFilter?>(
      stream: bloc.filters,
      builder: (context, filters) {
        return FilteredView<String, GroupGenderFilter?>(
          list: widget.matches,
          filterValue: filters,
          ignoreWhen: bloc.ignoreFilterWhen,
          filter: bloc.applyFilter,
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
                // Header
                Padding(
                  padding: AppResources.paddingContentHorizontal,
                  child: Row(
                    children: [
                      // Stats
                      Expanded(
                        child: Text(
                          'Affichage de ${filteredMatchesList.length} matches\nsur ${widget.matches.length}',   // TODO plural
                          style: context.textTheme.bodyMedium,
                        ),
                      ),

                      // Filters
                      AppResources.spacerMedium,
                      PmSegmentedButton(
                        options: GroupGenderFilter.values,
                        selected: filters,
                        iconBuilder: (value) => value.icon,
                        onSelectionChanged: bloc.updateFilter,
                      ),
                    ],
                  ),
                ),

                // Content
                AppResources.spacerSmall,
                Expanded(
                  child: ImplicitlyAnimatedList<String>(
                    items: filteredMatchesList,
                    areItemsTheSame: (a, b) => a == b,
                    padding: AppResources.paddingPageVertical.copyWith(top: 0),
                    itemBuilder: (context, animation, match, index) {
                      final group = AppService.names[match];
                      return SizeFadeTransition(
                        sizeFraction: 0.3,
                        curve: Curves.easeOut,
                        animation: animation,
                        child: VoteTile(match, group, widget.user.votes[match]?.value, key: ValueKey(match), dismissible: false),   // Using Dismissible with AnimatedList causes issues
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
  final filters = DataStream<GroupGenderFilter?>(null);

  bool ignoreFilterWhen(GroupGenderFilter? filterValue) => filterValue == null;
  bool applyFilter(String name, GroupGenderFilter? filter) {
    if (filter == null) return true;
    final group = AppService.names[name];
    if (group == null) return false;
    return filter.match(group);
  }

  void updateFilter(GroupGenderFilter? value) => filters.add(value);

  @override
  void dispose() {
    filters.close();
    super.dispose();
  }

}
