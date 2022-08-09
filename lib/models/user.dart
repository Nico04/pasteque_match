import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class UserData {
  const UserData({required this.name, this.partnerId, this.votes = const{}});

  /// User name
  final String name;

  /// Id of the user's partner, if any
  final String? partnerId;

  /// Map of votes
  /// <Name.id, SwipeValue>
  /// Using a map assure vote uniqueness
  final Map<String, SwipeValue> votes;

  bool get hasPartner => partnerId != null;

  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

class User extends UserData {
  const User({required this.id, required super.name, super.partnerId, super.votes});
  User.fromBase({required this.id, required UserData userData})
      : super(name: userData.name, partnerId: userData.partnerId, votes: userData.votes);

  final String id;

  factory User.fromJson(String id, Map<String, dynamic> json) => User.fromBase(id: id, userData: _$UserDataFromJson(json));
}

enum SwipeValue {
  dislike,
  like;
}
