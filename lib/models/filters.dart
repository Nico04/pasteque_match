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
    ValueGetter<bool?>? hyphenated,
    ValueGetter<GroupGenderFilter?>? groupGender,
  }) {
    // Build new filter object
    final filters = (dataStream.value.filters ?? const NameGroupFilters()).copyWith(
      firstLetter: firstLetter,
      length: length,
      hyphenated: hyphenated,
      groupGender: groupGender,
    );

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
    this.hyphenated = false,
    this.groupGender,
  });

  final String? firstLetter;

  static const lengthMin = 1.0;
  static const lengthMax = 20.0;
  static const lengthDivisions = lengthMax - lengthMin;
  static const lengthAll = RangeValues(lengthMin, lengthMax);
  final RangeValues length;

  final bool? hyphenated;

  final GroupGenderFilter? groupGender;

  bool match(NameGroup group) =>
      (firstLetter == null || group.names.any((name) => name.name.startsWith(firstLetter!))) &&
      (length == lengthAll || group.id.length >= length.start && group.id.length <= length.end) &&
      (hyphenated == null || group.names.first.isHyphenated == hyphenated) &&
      (groupGender == null || groupGender!.match(group));

  NameGroupFilters copyWith({
    ValueGetter<String?>? firstLetter,
    ValueGetter<RangeValues?>? length,
    ValueGetter<bool?>? hyphenated,
    ValueGetter<GroupGenderFilter?>? groupGender,
  }) => NameGroupFilters(
    firstLetter: firstLetter == null ? this.firstLetter : firstLetter(),
    length: length == null ? this.length : length() ?? lengthAll,
    hyphenated: hyphenated == null ? this.hyphenated : hyphenated(),
    groupGender: groupGender == null ? this.groupGender : groupGender(),
  );
}

enum GroupGenderFilter {
  atLeastOneFemale(Icons.female, 'Au moins une fille'),
  atLeastOneMale(Icons.male, 'Au moins un garçon'),
  epicene(Icons.transgender, 'Épicène');

  const GroupGenderFilter(this.icon, this.label);

  final IconData icon;
  final String? label;

  bool match(NameGroup group) => switch(this) {
    atLeastOneFemale => group.names.any((n) => n.gender == NameGender.female),
    atLeastOneMale => group.names.any((n) => n.gender == NameGender.male),
    epicene => group.epicene,
  };
}
