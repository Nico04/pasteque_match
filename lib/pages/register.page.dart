import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/database_service.dart';
import 'package:pasteque_match/services/storage_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

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

  Future<void> registerUser() async {
    final userId = await DatabaseService.addUser(username!);
    await StorageService.saveUserId(userId);
  }
}
