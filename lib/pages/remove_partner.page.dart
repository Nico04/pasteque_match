import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class RemovePartnerPage extends StatelessWidget {
  const RemovePartnerPage(this.partnerName, {super.key});

  final String partnerName;   // TODO Use field instead of direct AppService access so widget doesn't throw when rebuilt after deletion

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: 'Suppression du partenaire',
      child: SubmitBuilder<void>(
        task: AppService.instance.removePartner,
        onSuccess: (_) async {
          showMessage('Partenaire supprimé');
          context.popToRoot();
        },
        builder: (context, runTask) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  FontAwesomeIcons.faceSadCry,
                  size: 60,
                ),
                AppResources.spacerMedium,
                const Text('Êtes-vous sûr de vouloir supprimer votre partenaire ?'),
                AppResources.spacerMedium,
                Text(
                  partnerName,
                  style: context.textTheme.headlineMedium,
                ),
                AppResources.spacerHuge,
                const Text('Une fois supprimé, votre lien sera perdu.\nMais vous pourrez toujours re-faire le lien plus tard :)'),
                AppResources.spacerMedium,
                PmButton(
                  label: 'Supprimer votre partenaire',
                  onPressed: runTask,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
