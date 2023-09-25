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
            AppResources.spacerExtraLarge,
            Text(
              'QrCode de restauration',
              style: context.textTheme.titleMedium,
            ),
            AppResources.spacerTiny,
            Text(
              'Vous avez encore un⸱e partenaire lié à votre compte ?\nScannez le QrCode de restauration accessible depuis le menu de votre partenaire.',
              style: context.textTheme.bodySmall,
            ),
            AppResources.spacerMedium,
            ElevatedButton(
              onPressed: () {},
              child: const Text('Scanner un QrCode de restauration'),
            ),

            // ID section
            AppResources.spacerExtraLarge,
            Text(
              'ID utilisateur',
              style: context.textTheme.titleMedium,
            ),
            AppResources.spacerTiny,
            Text(
              'Vous avez conservé votre ID utilisateur ?\nEntrez votre ID utilisateur pour restaurer votre compte.',
              style: context.textTheme.bodySmall,
            ),
            AppResources.spacerMedium,
            TextFormField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                label: Text('Votre ID utilisateur'),
              ),
              inputFormatters: [ AppResources.maxLengthInputFormatter() ],
              textInputAction: TextInputAction.done,
              validator: AppResources.validatorNotEmpty,
            ),
            AppResources.spacerMedium,
            ElevatedButton(
              onPressed: () {},
              child: const Text('Restaurer mon compte'),
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
