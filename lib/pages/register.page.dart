import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/services/database_service.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

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
        onSuccess: () => navigateTo(context, (_) => const Text('TODO'), clearHistory: true),
        builder: (context, validate) {
          return SafeArea(
            child: Padding(
              padding: AppResources.paddingPage,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text('Choisissez un pseudo'),
                  AppResources.spacerExtraLarge,
                  TextFormField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
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
                    child: Text('Valider'),
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

  Future<void> registerUser() async => DatabaseService.addUser(username!);
}
