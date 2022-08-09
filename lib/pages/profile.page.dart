import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/scan_result.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/themed/pm_qr_code_widget.dart';

import 'remove_partner.page.dart';
import 'scan.page.dart';
import 'scan_result.page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage(this.user, {super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppResources.paddingPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Partner section
              _PartnerCard(
                userId: user.id,
                partnerId: user.partnerId,
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard({required this.userId, this.partnerId, super.key});

  final String userId;
  final String? partnerId;

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
            if (partnerId == null)...[
              const Text('Vous n\'avez pas encore de partenaire'),
              AppResources.spacerMedium,
              const Text('Votre code unique :'),
              AppResources.spacerMedium,
              PmQrCodeWidget(ScanResult.buildCode(userId)),
              AppResources.spacerMedium,
              ElevatedButton(
                onPressed: () => ScanPage.goToScanOrPermissionPage(context),
                onLongPress: kReleaseMode ? null : () => navigateTo(context, (_) => ScanResultPage('PM##cQp01G4xvrDGiHDJ9wT0')),
                child: const Text('Scanner le code de votre partenaire'),
              ),
            ]

            // With partner
            else ...[
              Text(
                AppService.instance.partner!.name,
                style: context.textTheme.headlineMedium,
              ),
              AppResources.spacerMedium,
              TextButton(
                style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.red)),
                onPressed: () => navigateTo(context, (_) => RemovePartnerPage(AppService.instance.partner!.name)),
                child: const Text('Supprimer votre partenaire'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
