import 'package:value_stream/value_stream.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/services/app_service.dart';
import 'package:pasteque_match/utils/_utils.dart';

import 'name.dart';

class FilteredNameGroupsHandler with Disposable {
  final dataStream = DataStream<FilteredNameGroups>(FilteredNameGroups());

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
    dataStream.add(FilteredNameGroups(filters));
  }

  @override
  void dispose() {
    dataStream.close();
    super.dispose();
  }
}

class FilteredNameGroups {
  FilteredNameGroups([this.filters]) {
    filtered = _buildFilteredList();
  }

  Map<String, NameGroup> get all => AppService.names;

  final NameGroupFilters? filters;
  late final Map<String, NameGroup> filtered;

  Map<String, NameGroup> _buildFilteredList() => filters == null ? all : Map.fromEntries(all.entries.where((e) => filters!.match(e.value)));
}

class NameGroupFilters {
  const NameGroupFilters({
    this.firstLetter,
    this.length = lengthAll,
    this.hyphenated,
    this.saint,
    this.groupGender,
  });

  final String? firstLetter;

  static const lengthMin = 3.0;
  static const lengthMax = 20.0;
  static const lengthDivisions = lengthMax - lengthMin;
  static const lengthAll = RangeValues(lengthMin, lengthMax);
  final RangeValues length;

  final BooleanFilter? hyphenated;
  final BooleanFilter? saint;

  final GroupGenderFilter? groupGender;

  int get count => (firstLetter != null ? 1 : 0) + (length != lengthAll ? 1 : 0) + (hyphenated != null ? 1 : 0) + (saint != null ? 1 : 0) + (groupGender != null ? 1 : 0);
  bool get isEmpty => count == 0;

  bool match(NameGroup group) =>
      (firstLetter == null || group.names.any((name) => name.name.startsWith(firstLetter!))) &&
      (length == lengthAll || group.id.length >= length.start && group.id.length <= length.end) &&
      (hyphenated == null || hyphenated!.match(group, (n) => n.isHyphenated)) &&
      (saint == null || saint!.match(group, (n) => n.isSaint)) &&
      (groupGender == null || groupGender!.match(group));

  List<String> getLabels() => [
    if (firstLetter != null) 'Commence par $firstLetter',
    if (length != lengthAll) 'Entre ${length.start.round()} et ${length.end.round()} caractères',
    if (hyphenated != null) '${hyphenated!.label} composé',
    if (saint != null) '${saint!.label} Saint',
    if (groupGender != null) groupGender!.label,
  ];

  NameGroupFilters copyWith({
    ValueGetter<String?>? firstLetter,
    ValueGetter<RangeValues?>? length,
    ValueGetter<BooleanFilter?>? hyphenated,
    ValueGetter<BooleanFilter?>? saint,
    ValueGetter<GroupGenderFilter?>? groupGender,
  }) => NameGroupFilters(
    firstLetter: firstLetter == null ? this.firstLetter : firstLetter(),
    length: length == null ? this.length : length() ?? lengthAll,
    hyphenated: hyphenated == null ? this.hyphenated : hyphenated(),
    saint: saint == null ? this.saint : saint(),
    groupGender: groupGender == null ? this.groupGender : groupGender(),
  );
}

enum GroupGenderFilter {
  atLeastOneFemale(Icons.female, 'Au moins une fille'),
  atLeastOneMale(Icons.male, 'Au moins un garçon'),
  epicene(Icons.transgender, 'Épicène');

  const GroupGenderFilter(this.icon, this.label);

  final IconData icon;
  final String label;

  bool match(NameGroup group) => switch(this) {
    atLeastOneFemale => group.names.any((n) => n.gender == NameGender.female),
    atLeastOneMale => group.names.any((n) => n.gender == NameGender.male),
    epicene => group.epicene,
  };
}

enum BooleanFilter {    // OPTI rename ?
  include(Icons.check, 'Au moins un'),
  exclude(Icons.close, 'Aucun');

  const BooleanFilter(this.icon, this.label);

  final IconData icon;
  final String label;

  bool match(NameGroup group, bool Function(Name name) valueGetter) => switch(this) {
    include => group.names.any(valueGetter),
    exclude => group.names.every((n) => !valueGetter(n)),
  };
}
