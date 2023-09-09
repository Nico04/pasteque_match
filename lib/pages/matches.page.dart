import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/scan_result.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';
import 'package:pasteque_match/widgets/themed/pm_qr_code_widget.dart';

import 'name_group.page.dart';
import 'scan.page.dart';
import 'partner.page.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return EventFetchBuilder<User>(
      stream: AppService.instance.userSession!.userStream,
      builder: (context, user) {
        return PmBasicPage(
          title: 'Matches',
          action: user.hasPartner ? IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => navigateTo(context, (context) => const PartnerPage()),
          ) : null,
          withScrollView: false,
          withPadding: false,
          child: () {
            if (user.hasPartner) {
              return _MatchesListView(user);
            } else {
              return Column(
                children: [
                  Padding(
                    padding: AppResources.paddingPage,
                    child: _AddPartnerCard(user.id),
                  ),
                ],
              );
            }
          } (),
        );
      },
    );
  }
}

class _AddPartnerCard extends StatelessWidget {
  const _AddPartnerCard(this.userId, {super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppResources.paddingContent,
        child: Column(
          children: [

            // Title
            Text(
              'Ajouter un partenaire',
              style: context.textTheme.titleLarge,
            ),

            // Caption
            AppResources.spacerLarge,
            const Text('Vous n\'avez pas encore de partenaire'),
            AppResources.spacerMedium,
            const Text('Votre code unique :'),
            AppResources.spacerMedium,
            PmQrCodeWidget(ScanResult.buildCode(userId)),
            AppResources.spacerMedium,
            ElevatedButton(
              onPressed: () => ScanPage.goToScanOrPermissionPage(context),
              child: const Text('Scanner le code de votre partenaire'),
            ),

          ],
        ),
      ),
    );
  }
}

class _MatchesListView extends StatelessWidget {
  const _MatchesListView(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return EventFetchBuilder<User?>(
      stream: AppService.instance.userSession!.partnerStream,
      builder: (context, partner) {
        return ValueBuilder<List<String>>(
          key: ValueKey(user.hashCode ^ partner.hashCode),
          valueGetter: () => AppService.instance.getMatches(user.likes, partner?.likes ?? []),
          builder: (context, matches) {
            if (matches.isEmpty) {
              return Container(
                padding: AppResources.paddingPage,
                alignment: Alignment.center,
                child: const Text('Aucun match pour le moment'),
              );
            }
            return ListView.separated(
              padding: AppResources.paddingPage,
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                final group = AppService.names[match]!;
                final names = group.names.skip(1).map((n) => n.name).toList(growable: false);
                return ListTile(
                  title: Text(match),
                  subtitle: names.isNotEmpty ? Text(names.join(', ')) : null,
                  onTap: () => navigateTo(context, (context) => NameGroupPage(group)),
                );
              },
              separatorBuilder: (_, __) => AppResources.spacerSmall,
            );
          }
        );
      },
    );
  }
}
