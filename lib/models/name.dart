import 'package:json_annotation/json_annotation.dart';
import 'package:pasteque_match/utils/extensions_base.dart';

part 'name.g.dart';

@JsonSerializable()
class Name {
  const Name({required this.name, required this.gender, this.otherNames = const[], required this.stats});

  String get id => name.normalized;

  final String name;
  final NameGender gender;
  final List<String> otherNames;
  final NameQuantityStatistics stats;

  NameRarity get rarity => NameRarity.common;   // TODO
  String get firstLetter => name.substringSafe(length: 1);
  int get length => name.length;
  bool get isHyphenated => name.contains('-') || name.contains("'");
  NameAge get age => NameAge.ancient;   // TODO

  factory Name.fromJson(Map<String, dynamic> json) => _$NameFromJson(json);
  Map<String, dynamic> toJson() => _$NameToJson(this);
}

@JsonSerializable(converters: [_NameGenderQuantityStatisticsConverter()])
class NameQuantityStatistics {
  const NameQuantityStatistics({this.male, this.female});

  @JsonKey(name: 'm')
  final NameGenderQuantityStatistics? male;
  @JsonKey(name: 'f')
  final NameGenderQuantityStatistics? female;

  int get total => (male?.total ?? 0) + (female?.total ?? 0);

  factory NameQuantityStatistics.fromJson(Map<String, dynamic> json) => _$NameQuantityStatisticsFromJson(json);
  Map<String, dynamic> toJson() => _$NameQuantityStatisticsToJson(this);
}

typedef NameGenderQuantityStatisticsValue = Map<int, int>;

class NameGenderQuantityStatistics {
  const NameGenderQuantityStatistics(this.values);

  /// Map<Year, Quantity>.
  /// Years with values under 3 are not included. All theses years are summed into a special Year == 0.
  final NameGenderQuantityStatisticsValue values;

  int get total => values.values.sum();
}

enum NameGender {
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

class _NameGenderQuantityStatisticsConverter implements JsonConverter<NameGenderQuantityStatistics, NameGenderQuantityStatisticsValue> {
  const _NameGenderQuantityStatisticsConverter();

  @override
  NameGenderQuantityStatistics fromJson(NameGenderQuantityStatisticsValue json) => NameGenderQuantityStatistics(json);

  @override
  NameGenderQuantityStatisticsValue toJson(NameGenderQuantityStatistics object) => object.values;
}
