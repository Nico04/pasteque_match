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
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 60,
                ),
                AppResources.spacerMedium,
                const Text('Le QrCode n\'est pas un partenaire valide'),
                AppResources.spacerMedium,
                ElevatedButton(
                  onPressed: () => context.popToRoot(),
                  child: const Text('Retour'),
                ),
              ],
            ),
          );
        } else {
          return FetchBuilder.basic<User?>(
            task: bloc.getPartner,
            builder: (context, partner) {
              return Text(partner?.name ?? 'None');   // TODO
            }
          );
        }
      } (),
    );
  }
}


class ScanResultPageBloc with Disposable {
  ScanResultPageBloc(this.scanResult);

  final ScanResult scanResult;

  Future<User?> getPartner() => AppService.database.getPartner(scanResult.userId!);
}
