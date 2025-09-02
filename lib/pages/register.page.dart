import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

import 'restore_account.page.dart';
import 'main.page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with BlocProvider<RegisterPage, RegisterPageBloc> {
  @override
  initBloc() => RegisterPageBloc();

  @override
  Widget build(BuildContext context) {
    return SubmitFormBuilder<void>(
      onValidated: bloc.registerUser,
      onSuccess: (_) => navigateTo(context, (_) => const MainPage(), clearHistory: true),
      builder: (context, validate) {
        return PmBasicPage(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              // Center
              Column(
                children: [
                  // Image
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      width: 150,
                      fit: BoxFit.scaleDown,
                    ),
                  ),

                  // Caption
                  AppResources.spacerExtraLarge,
                  AppResources.spacerExtraLarge,
                  Text(
                    'Choisissez un pseudo',
                    style: context.textTheme.titleMedium,
                  ),

                  // Field
                  AppResources.spacerExtraLarge,
                  TextFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(FontAwesomeIcons.user),
                      hintText: 'Pseudo',
                    ),
                    autofocus: true,
                    inputFormatters: [ AppResources.maxLengthInputFormatter() ],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) => validate(),
                    validator: AppResources.validatorNotEmpty,
                    onSaved: (value) => bloc.username = value,
                  ),

                  // Restore account
                  AppResources.spacerMedium,
                  Align(
                    alignment: Alignment.centerRight,
                    child: PmButton(
                      label: 'Restaurer mon compte',
                      isSecondary: true,
                      onPressed: () => navigateTo(context, (_) => const RestoreAccountPage()),
                    ),
                  ),
                ],
              ),

              // Button
              AppResources.spacerExtraLarge,
              PmButton(
                label: 'Valider',
                onPressed: validate,
              ),

            ],
          ),
        );
      },
    );
  }
}


class RegisterPageBloc with Disposable {
  String? username;

  Future<void> registerUser() => AppService.instance.registerUser(username!);
}
