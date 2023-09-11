import 'package:flutter/material.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> with BlocProvider<FilterPage, FilterPageBloc> {
  @override
  initBloc() => FilterPageBloc();

  @override
  Widget build(BuildContext context) {
    return ClearFocusBackground(
      child: PmBasicPage(
        title: 'Filtres',
        child: Column(
          children: [
            // Stats
            Text(
              'XXX groupes correspondent à vos critères',   // TODO
              style: context.textTheme.bodySmall,
            ),

            // First letter
            AppResources.spacerLarge,
            Row(
              children: [
                const Text('Commence par'),
                const Spacer(),
                SizedBox(
                  width: 50,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      AppResources.onlyLettersInputFormatter,
                      AppResources.maxLengthInputFormatter(1),
                    ],
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (value) => bloc.firstLetter = value,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}


class FilterPageBloc with Disposable {
  String? firstLetter;
}
