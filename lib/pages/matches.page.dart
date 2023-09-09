import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/scan_result.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';
import 'package:pasteque_match/widgets/themed/pm_qr_code_widget.dart';

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
          child: Column(
            children: [
              if (!user.hasPartner)
                _AddPartnerCard(user.id)
              else
                Text('TODO matches'),
            ],
          ),
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
