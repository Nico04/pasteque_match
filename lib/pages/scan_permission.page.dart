import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanPermissionPage extends StatelessWidget {
  const ScanPermissionPage({Key? key, required this.onGranted}) : super(key: key);

  final VoidCallback onGranted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan'),
      ),
      body: Padding(
        padding: AppResources.paddingPage,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppResources.spacerLarge,
            const Icon(
              FontAwesomeIcons.camera,
              size: 60,
            ),

            AppResources.spacerHuge,
            const Text(
              'Pour pouvoir scanner le QrCode de votre partenaire, l\'autorisation d\'accès à la camera est nécessaire.',
              textAlign: TextAlign.center,
            ),

            AppResources.spacerHuge,
            Center(
              child: PmButton(
                label: 'Suivant',
                onPressed: () => askPermission(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> askPermission(BuildContext context) async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      onGranted();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      showMessage(context, 'Permission refusée', isError: true);
    }
  }
}
