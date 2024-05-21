import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class VotesPage extends StatefulWidget {
  const VotesPage({super.key});

  @override
  State<VotesPage> createState() => _VotesPageState();
}

class _VotesPageState extends State<VotesPage>  with BlocProvider<VotesPage, VotesPageBloc> {
  @override
  initBloc() => VotesPageBloc();

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Mes votes',
      withPadding: false,
      withScrollView: false,
      actions: [
        DataStreamBuilder<VoteSortType>(
          stream: bloc.sortType,
          builder: (context, sortType) {
            return _SortButton(
              sortValue: sortType,
              onSortChanged: (value) => bloc.sortType.add(value, skipSame: true),
            );
          },
        ),
      ],
      child: EventStreamBuilder<User?>(   // TODO convert to EventFetchBuilder to handle loading state
        stream: AppService.instance.userSession!.userStream,
        builder: (context, snapshot) {
          final user = snapshot.data!;
          final votes = user.votes;
          if (votes.isEmpty) {
            return const Center(child: Text('Aucun votes'));
          }

          return Column(
            children: [
              // Stats
              Text(
                'Vous avez voté pour ${votes.length} prénoms,\ndont ${user.likes.length} prénoms que vous aimez.',
                style: context.textTheme.bodyMedium,
              ),

              // Content
              AppResources.spacerSmall,
              Expanded(
                child: DataStreamBuilder<VoteSortType>(
                  key: ObjectKey(votes),
                  stream: bloc.sortType,
                  builder: (context, sortType) {
                    return ValueBuilder<List<MapEntry<String, UserVote>>>(
                      key: ValueKey(sortType),
                      valueGetter: () => bloc.sortProperties(votes.entries.toList(), sortType),
                      builder: (context, sortedVoteEntries) {
                        return ListView.builder(
                          itemCount: votes.length,
                          itemBuilder: (context, index) {
                            final voteEntry = sortedVoteEntries[index];
                            final groupId = voteEntry.key;
                            final vote = voteEntry.value;
                            final group = AppService.names[groupId];
                            return VoteTile(groupId, group, vote.value, key: ValueKey(groupId));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({
    required this.sortValue,
    required this.onSortChanged,
  });

  /// Current sort value
  final VoteSortType sortValue;

  /// Called when sort method is tapped
  final ValueChanged<VoteSortType> onSortChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<VoteSortType>(
      icon: const Icon(Icons.sort),
      tooltip: 'Trier',
      onSelected: (value) {
        // Ignore if same value
        if (value != sortValue) onSortChanged(value);
      },
      itemBuilder: (context) {
        return VoteSortType.values.map((value) {
          return PopupMenuItem<VoteSortType>(
            value: value,
            child: Text(
              value.label,
              style: value == sortValue ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
            ),
          );
        }).toList(growable: false);
      },
    );
  }
}


class VotesPageBloc with Disposable {
  VotesPageBloc() {
    // Auto save sort type
    sortType.listen(AppService.instance.saveVoteSortType);
  }

  final sortType = DataStream(AppService.instance.voteSortType);

  List<MapEntry<String, UserVote>> sortProperties(List<MapEntry<String, UserVote>> votes, VoteSortType sortType) => switch (sortType) {
    VoteSortType.name => votes..sort((a, b) => a.key.compareTo(b.key)),
    VoteSortType.date => votes..sort((a, b) => b.value.date.compareTo(a.value.date)),
    VoteSortType.value => votes..sort((a, b) => b.value.value.index.compareTo(a.value.value.index)),
  };

  @override
  void dispose() {
    sortType.close();
    super.dispose();
  }
}
