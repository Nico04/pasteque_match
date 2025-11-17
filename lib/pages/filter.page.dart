import 'package:fetcher/fetcher_bloc.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/models/filters.dart';
import 'package:pasteque_match/resources/_resources.dart';
import 'package:pasteque_match/utils/_utils.dart';
import 'package:pasteque_match/widgets/_widgets.dart';

class FilterPage extends StatefulWidget {
  const FilterPage(this.holder, {super.key});

  final ValueHolder<FilteredNameGroups> holder;

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> with BlocProvider<FilterPage, FilterPageBloc> {
  @override
  initBloc() => FilterPageBloc(widget.holder);

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
              stream: bloc.dataStream,
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
                    ValueBuilder(
                      valueGetter: () => TextEditingController(text: filters.firstLetter),
                      builder: (context, controller) {
                        return Row(
                          children: [
                            const Text('Commence par'),
                            const Spacer(),
                            AppResources.spacerMedium,
                            SizedBox(
                              width: 50,
                              child: TextField(
                                controller: controller,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  AppResources.onlyLettersInputFormatter,
                                  AppResources.maxLengthInputFormatter(1),
                                ],
                                textInputAction: TextInputAction.done,
                                textCapitalization: TextCapitalization.characters,
                                onChanged: (value) => bloc.updateFilter(firstLetter: () => value.isEmpty ? null : value.toUpperCase()),
                              ),
                            ),
                            AppResources.spacerMedium,
                            IconButton(
                              icon: const Icon(FontAwesomeIcons.xmark),
                              onPressed: () {
                                bloc.updateFilter(firstLetter: () => null);
                                controller.clear();
                              },
                            ),
                          ],
                        );
                      },
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
                                onChanged: (values) => bloc.updateFilter(length: () => values),
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
                          icon: const Icon(FontAwesomeIcons.xmark),
                          onPressed: () => bloc.updateFilter(length: () => null),
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
                      onSelectionChanged: (value) => bloc.updateFilter(hyphenated: () => value),
                    ),

                    // Saint
                    AppResources.spacerMedium,
                    _SegmentedButtonFilter(
                      label: 'Saint',
                      options: BooleanFilter.values,
                      selected: filters.saint,
                      iconBuilder: (value) => value.icon,
                      labelBuilder: (value) => value.label,
                      onSelectionChanged: (value) => bloc.updateFilter(saint: () => value),
                    ),

                    // Gender
                    AppResources.spacerMedium,
                    _SegmentedButtonFilter(
                      label: 'Genre',
                      options: GroupGenderFilter.values,
                      selected: filters.groupGender,
                      iconBuilder: (value) => value.icon,
                      labelBuilder: (value) => value.label,
                      onSelectionChanged: (value) => bloc.updateFilter(groupGender: () => value),
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
              PmSegmentedButton<T>(
                options: options,
                selected: selected,
                iconBuilder: iconBuilder,
                onSelectionChanged: onSelectionChanged,
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
          icon: const Icon(FontAwesomeIcons.xmark),
          onPressed: () => onSelectionChanged(null),
        ),
      ],
    );
  }
}


class FilterPageBloc with Disposable {
  FilterPageBloc(this.holder) {
    dataStream = DataStream<FilteredNameGroups>(holder.value);
  }

  final ValueHolder<FilteredNameGroups> holder;

  late final DataStream<FilteredNameGroups> dataStream;

  void updateFilter({
    ValueGetter<String?>? firstLetter,
    ValueGetter<RangeValues?>? length,
    ValueGetter<BooleanFilter?>? hyphenated,
    ValueGetter<BooleanFilter?>? saint,
    ValueGetter<GroupGenderFilter?>? groupGender,
  }) {
    // Build new filter object
    NameGroupFilters? filters = (dataStream.value.filters ?? const NameGroupFilters()).copyWith(
      firstLetter: firstLetter,
      length: length,
      hyphenated: hyphenated,
      saint: saint,
      groupGender: groupGender,
    );
    if (filters.isEmpty) filters = null;

    // Update data
    final filteredNameGroups = FilteredNameGroups(filters);
    holder.value = filteredNameGroups;

    // Update UI
    dataStream.add(filteredNameGroups);
  }

  @override
  void dispose() {
    dataStream.close();
    super.dispose();
  }
}
