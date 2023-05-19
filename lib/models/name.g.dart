// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Name _$NameFromJson(Map<String, dynamic> json) => Name(
      name: json['name'] as String,
      gender: $enumDecode(_$NameGenderEnumMap, json['gender']),
      otherNames: (json['otherNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      stats: NameQuantityStatistics.fromJson(
          json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NameToJson(Name instance) => <String, dynamic>{
      'name': instance.name,
      'gender': _$NameGenderEnumMap[instance.gender]!,
      'otherNames': instance.otherNames,
      'stats': instance.stats,
    };

const _$NameGenderEnumMap = {
  NameGender.male: 'male',
  NameGender.female: 'female',
  NameGender.unisex: 'unisex',
};

NameQuantityStatistics _$NameQuantityStatisticsFromJson(
        Map<String, dynamic> json) =>
    NameQuantityStatistics(
      male:
          _$JsonConverterFromJson<Map<int, int>, NameGenderQuantityStatistics>(
              json['m'],
              const _NameGenderQuantityStatisticsConverter().fromJson),
      female:
          _$JsonConverterFromJson<Map<int, int>, NameGenderQuantityStatistics>(
              json['f'],
              const _NameGenderQuantityStatisticsConverter().fromJson),
    );

Map<String, dynamic> _$NameQuantityStatisticsToJson(
    NameQuantityStatistics instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull(
      'm',
      _$JsonConverterToJson<Map<int, int>, NameGenderQuantityStatistics>(
          instance.male,
          const _NameGenderQuantityStatisticsConverter().toJson));
  writeNotNull(
      'f',
      _$JsonConverterToJson<Map<int, int>, NameGenderQuantityStatistics>(
          instance.female,
          const _NameGenderQuantityStatisticsConverter().toJson));
  return val;
}

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
