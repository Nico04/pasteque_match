// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Name _$NameFromJson(Map<String, dynamic> json) => Name(
      name: json['name'] as String,
      gender: $enumDecode(_$NameGenderEnumMap, json['gender']),
    );

Map<String, dynamic> _$NameToJson(Name instance) => <String, dynamic>{
      'name': instance.name,
      'gender': _$NameGenderEnumMap[instance.gender]!,
    };

const _$NameGenderEnumMap = {
  NameGender.male: 'male',
  NameGender.female: 'female',
  NameGender.unisex: 'unisex',
};
