import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/scan_result.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';
import 'package:pasteque_match/widgets/themed/pm_qr_code_widget.dart';

import 'remove_partner.page.dart';
import 'scan.page.dart';
import 'scan_result.page.dart';

class PartnerPage extends StatelessWidget {
  const PartnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Partenaire',
      child: EventStreamBuilder<User?>(   // Don't use EventFetchBuilder here because it will not emmit null at start and so display an infinite loader.
        stream: AppService.instance.userSession!.partnerStream,
        builder: (context, snapshot) {
          final partner = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PartnerCard(AppService.instance.userSession!.userId, partner),
            ],
          );
        },
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard(this.userId, this.partner);

  final String userId;
  final User? partner;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppResources.paddingContent,
        child: Column(
          children: [

            // Title
            Text(
              'Votre partenaire',
              style: context.textTheme.titleLarge,
            ),

            // No partner
            AppResources.spacerLarge,
            if (partner == null)...[
              const Text('Vous n\'avez pas encore de partenaire'),
              AppResources.spacerMedium,
              const Text('Votre code unique :'),
              AppResources.spacerMedium,
              PmQrCodeWidget(ScanResult.buildCode(userId)),
              AppResources.spacerMedium,
              PmButton(
                label: 'Scanner le code de votre partenaire',
                onPressed: () => navigateTo(context, (_) => const ScanPage(ScanResultPageType.partner)),
              ),
            ]

            // With partner
            else ...[
              Text(
                partner!.name,
                style: context.textTheme.headlineMedium,
              ),
              AppResources.spacerExtraLarge,
              PmButton(
                label: 'Restaurer le compte de votre partenaire',
                isSecondary: true,
                onPressed: () => openRestorePartnerDialog(context),
              ),
              PmButton(
                label: 'Supprimer votre partenaire',
                isSecondary: true,
                color: Colors.red,
                onPressed: () => navigateTo(context, (_) => RemovePartnerPage(AppService.instance.userSession!.partner!.name)),   // TODO listen to partner changes
              ),
            ],
          ],
        ),
      ),
    );
  }

  void openRestorePartnerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurer le compte de votre partenaire'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Caption
            const Text('Scanner ce QrCode avec l\'appareil de votre partenaire pour restaurer son compte.'),

            // QrCode
            AppResources.spacerExtraLarge,
            PmQrCodeWidget(ScanResult.buildCode(partner!.id)),
          ],
        ),
        actions: [
          PmButton(
            label: 'OK',
            isSecondary: true,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
