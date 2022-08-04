// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      name: json['name'] as String,
      partnerId: json['partnerId'] as String?,
      votes: (json['votes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, $enumDecode(_$SwipeValueEnumMap, e)),
          ) ??
          const {},
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'partnerId': instance.partnerId,
      'votes':
          instance.votes.map((k, e) => MapEntry(k, _$SwipeValueEnumMap[e]!)),
    };

const _$SwipeValueEnumMap = {
  SwipeValue.dislike: 'dislike',
  SwipeValue.like: 'like',
};
