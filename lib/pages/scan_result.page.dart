import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/scan_result.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';

class ScanResultPage extends StatefulWidget {
  ScanResultPage(String scanResult, {super.key}) : scanResult = ScanResult(scanResult);

  final ScanResult scanResult;

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> with BlocProvider<ScanResultPage, ScanResultPageBloc> {
  @override
  initBloc() => ScanResultPageBloc(widget.scanResult);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du scan'),
      ),
      body: () {
        // Is NOT valid
        if (!widget.scanResult.isValid) {
          return const _ErrorMessage(
            icon: Icons.error_outline,
            message: 'Le QrCode n\'est pas un partenaire valide',
          );
        } else {
          return FetchBuilder.basic<User?>(
            task: bloc.getPartner,
            builder: (context, partner) {
              if (partner == null) {
                return const _ErrorMessage(
                  icon: Icons.sentiment_dissatisfied,
                  message: 'Aucun partenaire trouvé',
                );
              }

              if (partner.hasPartner) {
                return const _ErrorMessage(
                  icon: Icons.sentiment_dissatisfied,
                  message: 'Votre partenaire est déjà pris',
                );
              }

              return AsyncTaskBuilder<void>(
                task: bloc.choosePartner,
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
            }
          );
        }
      } (),
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


class ScanResultPageBloc with Disposable {
  ScanResultPageBloc(this.scanResult);

  final ScanResult scanResult;

  Future<User?> getPartner() => AppService.database.getPartner(scanResult.userId!);

  Future<void> choosePartner() => AppService.instance.choosePartner(scanResult.userId!);
}
