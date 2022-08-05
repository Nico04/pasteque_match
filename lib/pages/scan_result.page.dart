import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';

class ScanResultPage extends StatefulWidget {
  const ScanResultPage(this.scanResult, {Key? key}) : super(key: key);

  final String scanResult;

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
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Is NOT valid
            if (!bloc.isValid)...[
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
            ]

            // Is valid
            else...[
              Text('TODO'),
            ],

          ],
        ),
      ),
    );
  }
}


class ScanResultPageBloc with Disposable {
  ScanResultPageBloc(this.scanResult);

  final String scanResult;

  late final bool isValid = scanResult.startsWith(AppResources.qrCodeHeader);
}
