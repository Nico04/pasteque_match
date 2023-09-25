import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class RestoreAccountPage extends StatelessWidget {
  const RestoreAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClearFocusBackground(
      child: PmBasicPage(
        title: 'Restaurer mon compte',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Caption
            Text("Vous avez perdu l'accès à votre compte ?\nDeux possibilités s'offre à vous pour le restaurer.",
              style: context.textTheme.bodyMedium,
            ),

            // Scan section
            _Section(
              title: 'Scanner un QrCode de restauration',
              caption: 'Vous avez encore un⸱e partenaire lié à votre compte ?\nScannez le QrCode de restauration accessible depuis le menu de votre partenaire.',
              buttonData: ButtonData(
                label: 'Scanner un QrCode de restauration',
                onPressed: () {}, // TODO
              ),
            ),

            // ID section
            _Section(
              title: 'ID utilisateur',
              caption: 'Vous avez conservé votre ID utilisateur ?\nEntrez votre ID utilisateur pour restaurer votre compte.',
              child: TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  label: Text('Votre ID utilisateur'),
                ),
                inputFormatters: [ AppResources.maxLengthInputFormatter() ],
                textInputAction: TextInputAction.done,
                validator: AppResources.validatorNotEmpty,
              ),
              buttonData: ButtonData(
                label: 'Restaurer mon compte',
                onPressed: () {}, // TODO
              )
            ),

            // Caption
            AppResources.spacerExtraLarge,
            Text(
              'Si vous n\'avez plus aucun⸱e partenaire lié à votre compte et que vous avez perdu votre ID utilisateur, vous ne pourrez pas restaurer votre compte. Vous devrez alors créer un nouveau compte.',
              style: context.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({super.key, required this.title, required this.caption, this.child, required this.buttonData});

  final String title;
  final String caption;
  final Widget? child;
  final ButtonData buttonData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppResources.spacerExtraLarge,
        Text(
          title,
          style: context.textTheme.titleMedium,
        ),
        AppResources.spacerTiny,
        Text(
          caption,
          style: context.textTheme.bodySmall,
        ),
        if (child != null)...[
          AppResources.spacerMedium,
          child!,
        ],
        AppResources.spacerMedium,
        PmButton.fromData(buttonData),
      ],
    );
  }
}
