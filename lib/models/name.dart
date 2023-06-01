import 'package:json_annotation/json_annotation.dart';
import 'package:pasteque_match/utils/extensions_base.dart';

part 'name.g.dart';

@JsonSerializable()
class NameGroup {
  const NameGroup(this.id, this.names);

  final String id;    // TODO ID from name
  final List<Name> names;

  String get name => names.first.name;
  NameGroupGender get gender {
    final hasMale = names.any((n) => n.gender == NameGender.male);
    final hasFemale = names.any((n) => n.gender == NameGender.female);
    if (hasMale && hasFemale) return NameGroupGender.unisex;
    if (hasMale) return NameGroupGender.male;
    if (hasFemale) return NameGroupGender.female;
    throw UnsupportedError('Unsupported case');
  }

  factory NameGroup.fromJson(Map<String, dynamic> json) => _$NameGroupFromJson(json);
  Map<String, dynamic> toJson() => _$NameGroupToJson(this);
}

@JsonSerializable(converters: [_NameQuantityStatisticsConverter()])
class Name {
  const Name({required this.name, required this.gender, required this.stats});

  String get id => name.normalized;     // TODO remove

  final String name;
  final NameGender gender;
  final NameQuantityStatistics stats;

  String get firstLetter => name.substringSafe(length: 1);
  int get length => name.length;
  bool get isHyphenated => name.contains('-') || name.contains("'");
  NameRarity get rarity => NameRarity.common;   // TODO
  NameAge get age => NameAge.ancient;   // TODO

  factory Name.fromJson(Map<String, dynamic> json) => _$NameFromJson(json);
  Map<String, dynamic> toJson() => _$NameToJson(this);
}

typedef NameQuantityStatisticsValue = Map<String, int>;

class NameQuantityStatistics {
  const NameQuantityStatistics(this.values);

  /// Map<Year, Quantity>.
  /// Years with values under 3 are not included. All theses years are summed into a special Year == 0.
  final Map<String, int> values;    // TODO use Map<int, int> (need conversion)

  int get total => values.values.sum();

  NameQuantityStatisticsValue toJson() => const _NameQuantityStatisticsConverter().toJson(this);
}

enum NameGender {
  male,
  female,
}

enum NameGroupGender {
  male,
  female,
  unisex,
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

class _NameQuantityStatisticsConverter implements JsonConverter<NameQuantityStatistics, NameQuantityStatisticsValue> {
  const _NameQuantityStatisticsConverter();

  @override
  NameQuantityStatistics fromJson(NameQuantityStatisticsValue json) => NameQuantityStatistics(json);

  @override
  NameQuantityStatisticsValue toJson(NameQuantityStatistics object) => object.values;
}
