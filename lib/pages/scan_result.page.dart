import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/scan_result.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'main.page.dart';

enum ScanResultPageType { userRestore , partner }

class ScanResultPage extends StatelessWidget {
  ScanResultPage(this.type, String scanResult, {super.key}) : scanResult = ScanResult(scanResult);

  final ScanResultPageType type;
  final ScanResult scanResult;

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Résultat du scan',
      child: () {
        // Is NOT valid
        if (!scanResult.isValid) {
          return const _ErrorMessage(
            icon: Icons.error_outline,
            message: 'Le QrCode n\'est pas un utilisateur valide',
          );
        } else {
          return switch (type) {
            ScanResultPageType.userRestore => _UserResult(scanResult.userId!),
            ScanResultPageType.partner => _PartnerResult(scanResult.userId!),
          };
        }
      } (),
    );
  }
}

class _UserResult extends StatelessWidget {
  const _UserResult(this.userId, {super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return FetchBuilder.basic<User?>(
      task: () => AppService.database.getUser(userId),
      builder: (context, user) {
        if (user == null) {
          return const _ErrorMessage(
            icon: Icons.sentiment_dissatisfied,
            message: 'Utilisateur introuvable',
          );
        }

        return AsyncTaskBuilder<void>(
          task: () => AppService.instance.restoreUser(userId),
          onSuccess: (_) {
            showMessage(context, 'Bienvenue ${AppService.instance.userSession?.user?.name} !\nVotre compte a bien été restauré.');
            return navigateTo(context, (_) => const MainPage(), clearHistory: true);
          },
          builder: (context, runTask) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sentiment_satisfied_alt,
                    size: 60,
                  ),
                  AppResources.spacerMedium,
                  const Text('Utilisateur trouvé !'),
                  AppResources.spacerMedium,
                  Text(
                    user.name,
                    style: context.textTheme.headlineMedium,
                  ),
                  AppResources.spacerHuge,
                  const Text('Voulez-vous restorer ce compte ?'),
                  AppResources.spacerMedium,
                  PmButton(
                    label: 'Restaurer',
                    onPressed: runTask,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _PartnerResult extends StatelessWidget {
  const _PartnerResult(this.partnerId, {super.key});

  final String partnerId;

  @override
  Widget build(BuildContext context) {
    return FetchBuilder.basic<User?>(
      task: () => AppService.database.getUser(partnerId),
      builder: (context, partner) {
        if (partner == null) {
          return const _ErrorMessage(
            icon: Icons.sentiment_dissatisfied,
            message: 'Partenaire introuvable',
          );
        }

        if (partner.hasPartner) {
          return const _ErrorMessage(
            icon: Icons.sentiment_dissatisfied,
            message: 'Votre partenaire est déjà pris',
          );
        }

        return AsyncTaskBuilder<void>(
          task: () => AppService.instance.choosePartner(partnerId),
          onSuccess: (_) async {
            showMessage(context, 'Partenaire choisi !');
            context.popToRoot();
          },
          builder: (context, runTask) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sentiment_satisfied_alt,
                    size: 60,
                  ),
                  AppResources.spacerMedium,
                  const Text('Partenaire trouvé !'),
                  AppResources.spacerMedium,
                  Text(
                    partner.name,
                    style: context.textTheme.headlineMedium,
                  ),
                  AppResources.spacerHuge,
                  const Text('Une fois validé, vous serez lié l\'un à l\'autre.'),
                  AppResources.spacerMedium,
                  ElevatedButton(
                    onPressed: runTask,
                    child: const Text('Choisir comme partenaire'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.icon, required this.message, super.key});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 60,
          ),
          AppResources.spacerMedium,
          Text(message),
          AppResources.spacerMedium,
          ElevatedButton(
            onPressed: () => context.popToRoot(),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }
}
