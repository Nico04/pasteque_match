import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pasteque_match/utils/_utils.dart';

part 'user.g.dart';

@JsonSerializable()
class UserData {
  const UserData({required this.name, this.partnerId, this.votes = const{}, this.lastVotedAt});

  /// User name
  final String name;

  /// Id of the user's partner, if any
  final String? partnerId;

  /// Whether user has a partner or not
  bool get hasPartner => partnerId != null;

  /// Map of votes
  /// <Name.id, SwipeValue>
  /// Using a map assure vote uniqueness
  final Map<String, SwipeValue> votes;

  /// Date of the last vote
  /// Used to clean the database
  @NullableTimestampConverter()
  final DateTime? lastVotedAt;

  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

class User extends UserData {
  const User({required this.id, required super.name, super.partnerId, super.votes});
  User.fromBase({required this.id, required UserData userData})
      : super(name: userData.name, partnerId: userData.partnerId, votes: userData.votes, lastVotedAt: userData.lastVotedAt);

  final String id;

  factory User.fromJson(String id, Map<String, dynamic> json) => User.fromBase(id: id, userData: _$UserDataFromJson(json));
}

enum SwipeValue {
  dislike,
  like;
}
