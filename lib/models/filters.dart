import 'package:fetcher/fetcher.dart';
import 'package:flutter/material.dart';
import 'package:pasteque_match/utils/_utils.dart';

import 'name.dart';

class FilteredNameGroups with Disposable {
  FilteredNameGroups(this.allNames) {
    filteredNames = DataStream(_buildFilteredList());
    filters.addListener(update);
  }

  Map<String, NameGroup> allNames;
  late final DataStream<List<NameGroup>> filteredNames;

  final filters = NameGroupFilters();

  void update() => filteredNames.add(_buildFilteredList());
  List<NameGroup> _buildFilteredList() => allNames.values.where(filters.match).toList(growable: false);

  @override
  void dispose() {
    filters.dispose();
    filteredNames.close();
    super.dispose();
  }
}

class NameGroupFilters with ChangeNotifier {
  String? _firstLetter;
  String? get firstLetter => _firstLetter;
  set firstLetter(String? value) {
    _firstLetter = value?.toUpperCase();
    notifyListeners();
  }

  static const _lengthMin = 1.0;
  static const _lengthMax = 20.0;
  static const _lengthDivisions = _lengthMax - _lengthMin;
  static const _lengthAll = RangeValues(_lengthMin, _lengthMax);
  RangeValues _length = _lengthAll;
  RangeValues get length => _length;
  set length(RangeValues value) {
    _length = value;
    notifyListeners();
  }

  bool? _hyphenated = false;
  bool? get hyphenated => _hyphenated;
  set hyphenated(bool? value) {
    _hyphenated = value;
    notifyListeners();
  }

  GroupGenderFilter? _groupGender;
  GroupGenderFilter? get groupGender => _groupGender;
  set groupGender(GroupGenderFilter? value) {
    _groupGender = value;
    notifyListeners();
  }

  bool match(NameGroup group) =>
      firstLetter == null || group.names.any((name) => name.name.startsWith(firstLetter!)) &&
      length == _lengthAll || group.id.length >= length.start && group.id.length <= length.end &&
      hyphenated == null || group.names.first.isHyphenated == hyphenated &&
      groupGender == null || groupGender!.match(group);
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
