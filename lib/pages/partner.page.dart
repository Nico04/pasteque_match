import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'remove_partner.page.dart';

class PartnerPage extends StatelessWidget {
  const PartnerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Partenaire',
      child: EventFetchBuilder<User?>(
        stream: AppService.instance.userSession!.partnerStream,
        builder: (context, partner) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PartnerCard(partner!),
            ],
          );
        },
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  const _PartnerCard(this.partner, {super.key});

  final User partner;

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

            // Content
            AppResources.spacerLarge,
            Text(
              partner.name,
              style: context.textTheme.headlineMedium,
            ),
            AppResources.spacerMedium,
            TextButton(
              style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.red)),
              onPressed: () => navigateTo(context, (_) => RemovePartnerPage(partner.name)),
              child: const Text('Supprimer votre partenaire'),
            ),

          ],
        ),
      ),
    );
  }
}
