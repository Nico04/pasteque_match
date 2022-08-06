import 'package:flutter/material.dart';
import 'package:pasteque_match/models/scan_result.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/themed/pm_qr_code_widget.dart';

import 'scan.page.dart';

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
                child: const Text('Scanner le code de votre partenaire'),
              )
            ]

            // With partner
            else ...[
              const Text('TODO'),
            ],
          ],
        ),
      ),
    );
  }
}
