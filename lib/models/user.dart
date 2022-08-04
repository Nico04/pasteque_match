import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  const User({required this.name, this.partnerId, this.votes = const{}});

  /// User name
  final String name;

  /// Id of the user's partner, if any
  final String? partnerId;

  /// Map of votes
  /// <Name.id, SwipeValue>
  /// Using a map assure vote uniqueness
  final Map<String, SwipeValue> votes;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

enum SwipeValue {
  dislike,
  like;
}
