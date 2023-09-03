import 'dart:convert';

import 'package:flutter/material.dart';
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
  const Name({required this.name, required this.gender, required this.stats});
  Name.fromStrings({required this.name, required String gender, required String stats}) :
    gender = NameGender.values.firstWhere((e) => e.name == gender),
    stats = NameQuantityStatistics((jsonDecode(stats) as Map<String, dynamic>).cast());

  String get id => name.normalized;     // TODO remove

  final String name;    // TODO rename to label ?
  final NameGender gender;
  final NameQuantityStatistics stats;

  String get firstLetter => name.substringSafe(length: 1);
  int get length => name.length;
  bool get isHyphenated => name.contains('-') || name.contains("'");
  NameRarity get rarity => NameRarity.common;   // TODO
  NameAge get age => NameAge.ancient;   // TODO
}

typedef NameQuantityStatisticsValue = Map<String, int>;

class NameQuantityStatistics {
  const NameQuantityStatistics(this.values);

  /// Map<Year, Quantity>.
  /// Years with values under 3 are not included. All theses years are summed into a special Year == 0.
  final NameQuantityStatisticsValue values;    // TODO use Map<int, int> (need conversion)

  int get total => values.values.sum();

  NameQuantityStatisticsValue toJson() => values;
}

enum NameGender {
  male(Icons.male, Colors.blue),
  female(Icons.female, Colors.pink);

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
