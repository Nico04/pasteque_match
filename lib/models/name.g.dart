// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NameGroup _$NameGroupFromJson(Map<String, dynamic> json) => NameGroup(
      json['id'] as String,
      (json['names'] as List<dynamic>)
          .map((e) => Name.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NameGroupToJson(NameGroup instance) => <String, dynamic>{
      'id': instance.id,
      'names': instance.names,
    };

Name _$NameFromJson(Map<String, dynamic> json) => Name(
      name: json['name'] as String,
      gender: $enumDecode(_$NameGenderEnumMap, json['gender']),
      stats: const _NameQuantityStatisticsConverter()
          .fromJson(json['stats'] as Map<String, int>),
    );

Map<String, dynamic> _$NameToJson(Name instance) => <String, dynamic>{
      'name': instance.name,
      'gender': _$NameGenderEnumMap[instance.gender]!,
      'stats': const _NameQuantityStatisticsConverter().toJson(instance.stats),
    };

const _$NameGenderEnumMap = {
  NameGender.male: 'male',
  NameGender.female: 'female',
};
