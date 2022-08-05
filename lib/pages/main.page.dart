import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/pages/profile.page.dart';
import 'package:pasteque_match/pages/register.page.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/database_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/utils/exceptions/not_found_exception.dart';
import 'package:pasteque_match/widgets/_widgets.dart';
import 'package:swipe_cards/swipe_cards.dart';

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
                    onPressed: () => navigateTo(context, (_) => const ProfilePage()),
                  ),
                ),
              ),
            ),

            // Swipe cards
            Expanded(
              child: FetchBuilder.basic<List<Name>>(
                task: bloc.getRemainingNames,
                config: FetcherConfig(
                  reportError: (e, s, {reason}) {
                    if (e is NotFoundException) {
                      showMessage(context, 'Utilisateur introuvable', isError: true);
                      navigateTo(context, (_) => const RegisterPage(), clearHistory: true);
                    } else {
                      DefaultFetcherConfig.of(context).reportError?.call(e, s, reason: reason);
                    }
                  }
                ),
                builder: (context, names) {
                  return ValueBuilder<MatchEngine>(
                  key: ObjectKey(names),
                    valueGetter: () => _buildSwipeEngine(names),
                    builder: (context, matchEngine) {
                      return Padding(
                        padding: AppResources.paddingPage,
                        child: SwipeCards(
                          matchEngine: matchEngine,
                          onStackFinished: () => print('onStackFinished'),    // TODO
                          itemBuilder: (context, index, distance, slideRegion) => _NameCard(names[index]),
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

  MatchEngine _buildSwipeEngine(List<Name> names) {
    return MatchEngine(swipeItems: names.map((name) {
      void postSwipe(SwipeValue value) async {
        // Send request
        debugPrint('[Swipe] ${value.name} "${name.name}"');
        DatabaseService.addUserVote(name.id, value);
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

class _NameCard extends StatelessWidget {
  const _NameCard(this.name, {Key? key}) : super(key: key);

  final NameData name;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(36))),
      elevation: 3,
      child: Padding(
        padding: AppResources.paddingContent,
        child: Center(
          child: Text(
            name.name,
            style: context.textTheme.headlineLarge,
          ),
        ),
      ),
    );
  }
}


class MainPageBloc with Disposable {
  Future<List<Name>> getRemainingNames() async {
    // Get all names
    final allNames = await DatabaseService.getNames();

    // Get current user data
    final user = await DatabaseService.getUser();
    if (user == null) throw const NotFoundException('User not found');

    // Compute remaining votes
    final votedNamesId = user.votes.keys;
    return allNames.where((name) => !votedNamesId.contains(name.id)).toList(growable: false);   // TODO sort random ?
  }
}
