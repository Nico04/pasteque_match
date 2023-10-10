import 'package:fetcher/fetcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class ResultPage extends StatelessWidget {
  const ResultPage(this.userId, {super.key});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Résultat',
      child: _UserResult(userId),
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
            icon: FontAwesomeIcons.faceFrownOpen,
            message: 'Utilisateur introuvable',
          );
        }

        return _UserFoundResultContent(
          task: () => AppService.instance.restoreUser(userId),
          onSuccess: (_) {
            showMessage(context, 'Votre compte a bien été restauré.');
            return navigateTo(context, (_) => const MainPage(), clearHistory: true);
          },
          caption: 'Utilisateur trouvé !',
          username: user.name,
          buttonCaption: 'Voulez-vous restorer ce compte ?',
          buttonLabel: 'Restaurer le compte',
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
            icon: FontAwesomeIcons.faceFrownOpen,
            message: 'Partenaire introuvable',
          );
        }

        if (partner.hasPartner) {
          return const _ErrorMessage(
            icon: FontAwesomeIcons.faceFrownOpen,
            message: 'Votre partenaire est déjà pris',
          );
        }

        return _UserFoundResultContent(
          task: () => AppService.instance.choosePartner(partnerId),
          onSuccess: (_) async {
            showMessage(context, 'Partenaire choisi !');
            context.popToRoot();
          },
          caption: 'Partenaire trouvé !',
          username: partner.name,
          buttonCaption: 'Une fois validé, vous serez lié l\'un à l\'autre.',
          buttonLabel: 'Choisir comme partenaire',
        );
      },
    );
  }
}

class _UserFoundResultContent extends StatelessWidget {
  const _UserFoundResultContent({
    super.key,
    required this.task,
    required this.onSuccess,
    required this.caption,
    required this.username,
    required this.buttonCaption,
    required this.buttonLabel,
  });

  final AsyncValueGetter<void> task;
  final AsyncValueSetter<void>? onSuccess;
  final String caption;
  final String username;
  final String buttonCaption;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return AsyncTaskBuilder<void>(
      task: task,
      onSuccess: onSuccess,
      builder: (context, runTask) {
        return Center(
          child: Column(
            children: [
              const Icon(
                FontAwesomeIcons.faceGrin,
                size: 60,
              ),
              AppResources.spacerMedium,
              Text(caption),
              AppResources.spacerMedium,
              Text(
                username,
                style: context.textTheme.headlineMedium,
              ),
              AppResources.spacerHuge,
              Text(buttonCaption),
              AppResources.spacerMedium,
              PmButton(
                label: buttonLabel,
                onPressed: runTask,
              ),
            ],
          ),
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
          PmButton(
            label: 'Retour',
            onPressed: () => context.popToRoot(),
          ),
        ],
      ),
    );
  }
}
