// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
      name: json['name'] as String,
      fcmToken: json['fcmToken'] as String?,
      partnerId: json['partnerId'] as String?,
      votes: (json['votes'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, UserVote.fromJson(e as Map<String, dynamic>)),
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

  writeNotNull('fcmToken', instance.fcmToken);
  writeNotNull('partnerId', instance.partnerId);
  val['votes'] = instance.votes;
  return val;
}

UserVote _$UserVoteFromJson(Map<String, dynamic> json) => UserVote(
      $enumDecode(_$SwipeValueEnumMap, json['value']),
      DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$UserVoteToJson(UserVote instance) => <String, dynamic>{
      'value': _$SwipeValueEnumMap[instance.value]!,
      'date': instance.date.toIso8601String(),
    };

const _$SwipeValueEnumMap = {
  SwipeValue.dislike: 'dislike',
  SwipeValue.superLike: 'superLike',
  SwipeValue.like: 'like',
};
