import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/filters.dart';
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Content
            Column(
              children: [
                // Caption
                Text(
                  'Filtrer les groupes de noms',
                  style: context.textTheme.bodyMedium,
                ),

                // Stats
                AppResources.spacerTiny,
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
                    AppResources.spacerMedium,
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

                // Length
                AppResources.spacerMedium,
                Row(
                  children: [
                    const Text('Longueur'),
                    AppResources.spacerMedium,
                    Expanded(
                      child: Column(
                        children: [
                          // Slider
                          RangeSlider(
                            values: bloc.length,
                            min: FilterPageBloc._lengthMin,
                            max: FilterPageBloc._lengthMax,
                            divisions: FilterPageBloc._lengthDivisions.toInt(),
                            labels: RangeLabels(
                              bloc.length.start.round().toString(),
                              bloc.length.end.round().toString(),
                            ),
                            onChanged: (RangeValues values) => setState(() => bloc.length = values),
                          ),

                          // Label
                          Text(
                            'Entre ${bloc.length.start.round()} et ${bloc.length.end.round()} lettres',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => bloc.length = FilterPageBloc._lengthAll),
                    ),
                  ],
                ),

                // Hyphenation
                AppResources.spacerMedium,
                CheckboxListTile(
                  title: const Text('Composé'),
                  tristate: true,
                  value: bloc.hyphenated,
                  onChanged: (value) => setState(() => bloc.hyphenated = value),
                ),

                // Gender
                AppResources.spacerMedium,
                Row(
                  children: [
                    const Text('Genre'),
                    AppResources.spacerMedium,
                    Expanded(
                      child: Column(
                        children: [
                          // Buttons
                          SegmentedButton<GroupGenderFilter>(
                            selected: {if (bloc.groupGender != null) bloc.groupGender!},
                            segments: GroupGenderFilter.values.map((value) => ButtonSegment(
                              value: value,
                              icon: Icon(value.icon),
                            )).toList(growable: false),
                            multiSelectionEnabled: false,
                            showSelectedIcon: false,
                            emptySelectionAllowed: true,
                            onSelectionChanged: (value) => setState(() => bloc.groupGender = value.isEmpty ? null : value.single),
                          ),

                          // Label
                          if (bloc.groupGender != null)...[
                            AppResources.spacerTiny,
                            Text(
                              bloc.groupGender!.label!,
                              style: context.textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => bloc.groupGender = null),
                    ),
                  ],
                ),

              ],
            ),

            // Button
            AppResources.spacerExtraLarge,
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuer'),
            ),
          ],
        ),
      ),
    );
  }
}


class FilterPageBloc with Disposable {
  String? firstLetter;

  static const _lengthMin = 1.0;
  static const _lengthMax = 20.0;
  static const _lengthDivisions = _lengthMax - _lengthMin;
  static const _lengthAll = RangeValues(_lengthMin, _lengthMax);
  RangeValues length = _lengthAll;

  bool? hyphenated = false;

  GroupGenderFilter? groupGender;
}
