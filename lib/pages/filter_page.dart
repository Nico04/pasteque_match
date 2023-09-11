import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/models/filters.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class FilterPage extends StatelessWidget {
  const FilterPage(this.filterHandler, {super.key});

  final FilteredNameGroupsHandler filterHandler;

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
            DataStreamBuilder<FilteredNameGroups>(
              stream: filterHandler.dataStream,
              builder: (context, filteredData) {
                final filters = filteredData.filters ?? const NameGroupFilters();
                return Column(
                  children: [
                    // Caption
                    Text(
                      'Filtrer les groupes de noms',
                      style: context.textTheme.bodyMedium,
                    ),

                    // Stats
                    AppResources.spacerTiny,
                    Text(
                      '${filteredData.filtered.length} groupes correspondent à vos critères',
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
                            controller: TextEditingController(text: filters.firstLetter),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              AppResources.onlyLettersInputFormatter,
                              AppResources.maxLengthInputFormatter(1),
                            ],
                            textInputAction: TextInputAction.done,
                            textCapitalization: TextCapitalization.characters,
                            onChanged: (value) => filterHandler.updateFilter(firstLetter: () => value),
                          ),
                        ),
                        AppResources.spacerMedium,
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => filterHandler.updateFilter(firstLetter: () => null),
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
                              _NameLengthSlider(
                                initialValue: filters.length,
                                onChanged: (values) => filterHandler.updateFilter(length: () => values),
                              ),

                              // Label
                              Text(
                                'Entre ${filters.length.start.round()} et ${filters.length.end.round()} lettres',
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => filterHandler.updateFilter(length: () => null),
                        ),
                      ],
                    ),

                    // Hyphenation
                    AppResources.spacerMedium,
                    CheckboxListTile(
                      title: const Text('Composé'),
                      tristate: true,
                      value: filters.hyphenated,
                      onChanged: (value) => filterHandler.updateFilter(hyphenated: () => value),
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
                                selected: {if (filters.groupGender != null) filters.groupGender!},
                                segments: GroupGenderFilter.values.map((value) => ButtonSegment(
                                  value: value,
                                  icon: Icon(value.icon),
                                )).toList(growable: false),
                                multiSelectionEnabled: false,
                                showSelectedIcon: false,
                                emptySelectionAllowed: true,
                                onSelectionChanged: (value) => filterHandler.updateFilter(groupGender: () => value.firstOrNull),
                              ),

                              // Label
                              if (filters.groupGender != null)...[
                                AppResources.spacerTiny,
                                Text(
                                  filters.groupGender!.label!,
                                  style: context.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => filterHandler.updateFilter(groupGender: () => null),
                        ),
                      ],
                    ),

                  ],
                );
              },
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

/// Small wrapper around RangeSlider to optimize rebuilds (rebuilt on onChanged, but commit changes on onChangeEnd).
class _NameLengthSlider extends StatefulWidget {
  const _NameLengthSlider({super.key, required this.initialValue, required this.onChanged});

  final RangeValues initialValue;
  final ValueChanged<RangeValues> onChanged;

  @override
  State<_NameLengthSlider> createState() => _NameLengthSliderState();
}

class _NameLengthSliderState extends State<_NameLengthSlider> {
  late RangeValues length = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      values: length,
      min: NameGroupFilters.lengthMin,
      max: NameGroupFilters.lengthMax,
      divisions: NameGroupFilters.lengthDivisions.toInt(),
      labels: RangeLabels(
        length.start.round().toString(),
        length.end.round().toString(),
      ),
      onChanged: (RangeValues values) => setState(() => length = values),
      onChangeEnd: widget.onChanged,
    );
  }
}
