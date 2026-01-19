import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/models/name.dart';
import 'package:pasteque_match/models/user.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'name.page.dart';

class NameGroupPage extends StatelessWidget {
  const NameGroupPage(this.group, {super.key});

  final NameGroup group;

  @override
  Widget build(BuildContext context) {
    return PmBasicPage(
      title: group.id,
      actions: [
        EventStreamBuilder(
          stream: AppService.instance.userSession!.userStream,
          builder: (context, asyncSnapshot) {
            if (!asyncSnapshot.hasData) {
              return const SizedBox();
            }
            final isHidden = asyncSnapshot.data!.isNameHidden(group.id);
            return IconButton(
              icon: isHidden
                  ? const Icon(FontAwesomeIcons.eyeSlash)
                  : const Icon(FontAwesomeIcons.eye),
              tooltip: '${isHidden ? 'Afficher' : 'Masquer'} ce groupe sur la page Matches',
              onPressed: () => AppService.instance.setUserHiddenNameSafe(group.id, !isHidden),
            );
          },
        ),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Column(
            children: [
              Text(
                'Groupe ${group.id}',
                style: context.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              AppResources.spacerLarge,
              Card(
                child: Padding(
                  padding: AppResources.paddingContent,
                  child: Column(
                    children: [
                      Text(
                        'Mon vote',
                        style: context.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      AppResources.spacerMedium,
                      EventFetchBuilder<User>(
                        stream: AppService.instance.userSession!.userStream,
                        builder: (context, user) => VoteTile(group.id, group, user.votes[group.id]?.value, dismissible: false, clickable: false),
                      ),
                    ],
                  ),
                ),
              ),
              AppResources.spacerLarge,
              Text(
                'Ce groupe contient ${group.names.length} noms :',
                style: context.textTheme.titleMedium,
              ),
              Text(
                '(Trié par popularité)',
                style: context.textTheme.bodySmall,
              ),
              AppResources.spacerMedium,
              ...group.names.map<Widget>(NameTile.new).toList()..insertBetween(AppResources.spacerSmall),
            ],
          ),

          // Flag
          AppResources.spacerMedium,
          ReportButton(group.id),
        ],
      ),
    );
  }
}

class NameTile extends StatelessWidget {
  const NameTile(this.name, {super.key});

  final Name name;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => navigateTo(context, (context) => NamePage(name)),
        child: Padding(
          padding: AppResources.paddingContent,
          child: Row(
            children: [
              Text(name.name),
              AppResources.spacerTiny,
              Text(
                '(${name.totalCount})',    // TODO use better indicator
                style: context.textTheme.bodySmall,
              ),
              const Spacer(),
              AppResources.spacerTiny,
              if (name.isSaint) const Text('😇'),
              AppResources.spacerTiny,
              GenderIcon(name.gender),
            ],
          ),
        ),
      ),
    );
  }
}

class ReportButton extends StatefulWidget {
  const ReportButton(this.groupId, {super.key});

  final String groupId;

  @override
  State<ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  String? comment;

  @override
  Widget build(BuildContext context) {
    return PmButton(
      label: 'Signaler un problème',
      isSecondary: true,
      onPressed: () => askConfirmation(
        context: context,
        title: 'Signaler un problème',
        caption: 'Vous avez constaté un problème avec ce groupe ?\nSignalez-le pour que nous puissions le corriger.',
        form: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Commentaire',
            hintText: 'Détaillez le problème',
          ),
          inputFormatters: [AppResources.maxLengthInputFormatter()],
          validator: (value) => AppResources.validatorMinLength(value, 5),
          onSaved: (value) => comment = value,
        ),
        confirmText: 'Signaler',
        onConfirmation: () async {
          await AppService.database.reportGroupError(widget.groupId, comment!);
          showMessage('Merci, le problème est signalé !');
        },
      ),
    );
  }
}
