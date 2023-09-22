import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart' hide ValueGetter;
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
                                key: ValueKey(filters.length),
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
                    _SegmentedButtonFilter(
                      label: 'Composé',
                      options: BooleanFilter.values,
                      selected: filters.hyphenated,
                      iconBuilder: (value) => value.icon,
                      labelBuilder: (value) => value.label,
                      onSelectionChanged: (value) => filterHandler.updateFilter(hyphenated: () => value),
                    ),

                    // Gender
                    AppResources.spacerMedium,
                    _SegmentedButtonFilter(
                      label: 'Genre',
                      options: GroupGenderFilter.values,
                      selected: filters.groupGender,
                      iconBuilder: (value) => value.icon,
                      labelBuilder: (value) => value.label,
                      onSelectionChanged: (value) => filterHandler.updateFilter(groupGender: () => value),
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

class _SegmentedButtonFilter<T extends Object> extends StatelessWidget {
  const _SegmentedButtonFilter({
    super.key,
    required this.label,
    required this.options,
    this.selected,
    required this.iconBuilder,
    required this.labelBuilder,
    required this.onSelectionChanged,
  });

  final String label;
  final List<T> options;
  final T? selected;
  final IconBuilder<T> iconBuilder;
  final LabelBuilder<T> labelBuilder;
  final ValueChanged<T?> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        AppResources.spacerMedium,
        Expanded(
          child: Column(
            children: [
              // Buttons
              SegmentedButton<T>(
                selected: {if (selected != null) selected!},
                segments: options.map((value) => ButtonSegment(
                  value: value,
                  icon: Icon(iconBuilder(value)),
                )).toList(growable: false),
                multiSelectionEnabled: false,
                showSelectedIcon: false,
                emptySelectionAllowed: true,
                onSelectionChanged: (value) => onSelectionChanged(value.firstOrNull),
              ),

              // Label
              if (selected != null)...[
                AppResources.spacerTiny,
                Text(
                  labelBuilder(selected!),
                  style: context.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => onSelectionChanged(null),
        ),
      ],
    );
  }
}
