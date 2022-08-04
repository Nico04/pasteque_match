// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NameData _$NameDataFromJson(Map<String, dynamic> json) => NameData(
      name: json['name'] as String,
      gender: $enumDecode(_$NameGenderEnumMap, json['gender']),
      otherNames: (json['otherNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$NameDataToJson(NameData instance) => <String, dynamic>{
      'name': instance.name,
      'gender': _$NameGenderEnumMap[instance.gender]!,
      'otherNames': instance.otherNames,
    };

const _$NameGenderEnumMap = {
  NameGender.male: 'male',
  NameGender.female: 'female',
  NameGender.unisex: 'unisex',
};
