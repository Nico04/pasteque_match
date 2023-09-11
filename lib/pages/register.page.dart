import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';

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
    return Scaffold(
      body: AsyncForm(
        onValidated: bloc.registerUser,
        onSuccess: () => navigateTo(context, (_) => const MainPage(), clearHistory: true),
        builder: (context, validate) {
          return SafeArea(
            child: Padding(
              padding: AppResources.paddingPage,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Text('Choisissez un pseudo'),
                  AppResources.spacerExtraLarge,
                  TextFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Pseudo',
                    ),
                    autofocus: true,
                    inputFormatters: [ AppResources.maxLengthInputFormatter() ],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (value) => validate(),
                    validator: AppResources.validatorNotEmpty,
                    onSaved: (value) => bloc.username = value,
                  ),
                  AppResources.spacerExtraLarge,
                  ElevatedButton(
                    onPressed: validate,
                    child: const Text('Valider'),
                  ),

                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


class RegisterPageBloc with Disposable {
  String? username;

  Future<void> registerUser() => AppService.instance.registerUser(username!);
}
