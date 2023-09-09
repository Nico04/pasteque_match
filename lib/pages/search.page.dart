import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';

import 'name_group.page.dart';

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
        body: DataStreamBuilder<List<NameGroup>?>(
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
                      return ListTile(
                        title: Text(group.name),
                        onTap: () => navigateTo(context, (context) => NameGroupPage(group)),
                      );
                    },
                  ),
                ),
              ],
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
