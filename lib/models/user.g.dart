// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      name: json['name'] as String,
      partnerId: json['partnerId'] as String?,
      votes: (json['votes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, $enumDecode(_$SwipeValueEnumMap, e)),
          ) ??
          const {},
    );

Map<String, dynamic> _$UserDataToJson(UserData instance) {
  final val = <String, dynamic>{
    'name': instance.name,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('partnerId', instance.partnerId);
  val['votes'] =
      instance.votes.map((k, e) => MapEntry(k, _$SwipeValueEnumMap[e]!));
  return val;
}

const _$SwipeValueEnumMap = {
  SwipeValue.dislike: 'dislike',
  SwipeValue.like: 'like',
};
