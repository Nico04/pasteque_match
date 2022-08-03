import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppResources.paddingPage,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text('Choisissez un pseudo'),
              AppResources.spacerExtraLarge,
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Pseudo',
                ),
              ),
              AppResources.spacerExtraLarge,
              ElevatedButton(
                onPressed: () {},
                child: Text('Valider'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
