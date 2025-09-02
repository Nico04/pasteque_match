import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with BlocProvider<SearchPage, SearchPageBloc> {
  @override
  initBloc() => SearchPageBloc();

  @override
  Widget build(BuildContext context) {
    return ClearFocusBackground(
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            decoration: const InputDecoration(
              hintText: 'Recherchez un prénom',
            ),
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: bloc.search,
          ),
        ),
        body: EventStreamBuilder<User>(   // Don't use EventFetchBuilder here because it ok to display empty vote values.
          stream: AppService.instance.userSession!.userStream,
          builder: (context, snapshot) {
            final userVotes = snapshot.data?.votes ?? {};
            return DataStreamBuilder<List<NameGroup>?>(
              stream: bloc.searchResult,
              builder: (context, searchResult) {
                if (searchResult == null) return const Center(child: Text('Recherchez un prénom'));
                if (searchResult.isEmpty) return const Center(child: Text('Aucun résultat'));
                return Column(
                  children: [

                    // Stats
                    AppResources.spacerMedium,
                    Text(
                      '${searchResult.length} résultats',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    // Results
                    AppResources.spacerMedium,
                    Expanded(
                      child: ListView.builder(
                        itemCount: searchResult.length,
                        itemBuilder: (context, index) {
                          final group = searchResult[index];
                          return VoteTile(group.id, group, userVotes[group.id]?.value, dismissible: false);
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}


class SearchPageBloc with Disposable {
  final searchResult = DataStream<List<NameGroup>?>(null);

  void search(String query) {
    final names = AppService.names;
    final result = names.values.where((e) => e.names.any((n) => n.name.normalized.contains(query.normalized))).toList(growable: false);
    searchResult.add(result);
  }

  @override
  void dispose() {
    searchResult.close();
    super.dispose();
  }
}
