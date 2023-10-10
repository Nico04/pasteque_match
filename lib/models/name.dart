import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pasteque_match/utils/extensions_base.dart';

class NameGroup {
  const NameGroup(this.id, this.epicene, this.names);
  NameGroup.fromStrings({required this.id, required String epicene}) :
    epicene = bool.parse(epicene),
    names = [];

  final String id;
  String get name => id;

  final bool epicene;

  final List<Name> names;
}

class Name {
  const Name({required this.name, required this.gender, required this.countByYear, required this.totalCount, required this.relativeCountByYear, required this.isHyphenated, this.saintDates});
  Name.fromStrings({required this.name, required String gender, required String countByYear, required String totalCount, required String relativeCountByYear, required String isHyphenated, List<String>? saintDates}) :
    gender = NameGender.values.firstWhere((e) => e.name == gender),
    countByYear = (jsonDecode(countByYear) as Map<String, dynamic>).cast(),
    totalCount = int.parse(totalCount),
    relativeCountByYear = (jsonDecode(relativeCountByYear) as Map<String, dynamic>).cast(),
    isHyphenated = bool.parse(isHyphenated),
    saintDates = saintDates?.map((e) => e.tryParseDate()).whereNotNull().toList(growable: false);

  final String name;    // TODO rename to label ?
  final NameGender gender;
  final NameQuantityStatisticsValue countByYear;
  final int totalCount;
  final NameQuantityStatisticsValue relativeCountByYear;
  final bool isHyphenated;
  final List<DateTime>? saintDates;

  String get firstLetter => name.substringSafe(length: 1);
  int get length => name.length;
  bool get isSaint => saintDates != null && saintDates!.isNotEmpty;
  NameRarity get rarity => NameRarity.common;   // TODO
  NameAge get age => NameAge.ancient;   // TODO
}

/// Map<Year, Quantity>.
/// Years with values under 3 are not included. All theses years are summed into a special Year == 0.
typedef NameQuantityStatisticsValue = Map<String, int>;

enum NameGender {
  male(FontAwesomeIcons.mars, Colors.blue),
  female(FontAwesomeIcons.venus, Colors.pink);

  const NameGender(this.icon, this.color);

  final IconData icon;
  final Color color;
}

enum NameRarity {
  veryRare,
  rare,
  common,
  popular,
}

enum NameAge {
  timeless,
  ancient,
  recent,
}
