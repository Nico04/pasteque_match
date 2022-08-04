// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      name: json['name'] as String,
      partnerId: json['partnerId'] as String?,
      votes: (json['votes'] as List<dynamic>?)
              ?.map((e) => Vote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'partnerId': instance.partnerId,
      'votes': instance.votes,
    };

Vote _$VoteFromJson(Map<String, dynamic> json) => Vote(
      json['nameId'] as String,
      $enumDecode(_$SwipeValueEnumMap, json['value']),
    );

Map<String, dynamic> _$VoteToJson(Vote instance) => <String, dynamic>{
      'nameId': instance.nameId,
      'value': _$SwipeValueEnumMap[instance.value]!,
    };

const _$SwipeValueEnumMap = {
  SwipeValue.dislike: 'dislike',
  SwipeValue.like: 'like',
};
