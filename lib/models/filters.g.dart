// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NameGroupFilters _$NameGroupFiltersFromJson(Map<String, dynamic> json) =>
    NameGroupFilters(
      firstLetter: json['firstLetter'] as String?,
      length: json['length'] == null
          ? NameGroupFilters.lengthAll
          : const RangeValuesConverter().fromJson(json['length'] as String),
      hyphenated: $enumDecodeNullable(
        _$BooleanFilterEnumMap,
        json['hyphenated'],
      ),
      saint: $enumDecodeNullable(_$BooleanFilterEnumMap, json['saint']),
      groupGender: $enumDecodeNullable(
        _$GroupGenderFilterEnumMap,
        json['groupGender'],
      ),
    );

Map<String, dynamic> _$NameGroupFiltersToJson(NameGroupFilters instance) =>
    <String, dynamic>{
      'firstLetter': ?instance.firstLetter,
      'length': const RangeValuesConverter().toJson(instance.length),
      'hyphenated': ?_$BooleanFilterEnumMap[instance.hyphenated],
      'saint': ?_$BooleanFilterEnumMap[instance.saint],
      'groupGender': ?_$GroupGenderFilterEnumMap[instance.groupGender],
    };

const _$BooleanFilterEnumMap = {
  BooleanFilter.include: 'include',
  BooleanFilter.exclude: 'exclude',
};

const _$GroupGenderFilterEnumMap = {
  GroupGenderFilter.atLeastOneFemale: 'atLeastOneFemale',
  GroupGenderFilter.atLeastOneMale: 'atLeastOneMale',
  GroupGenderFilter.epicene: 'epicene',
};
