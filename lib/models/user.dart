import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  const User({required this.name, this.partnerId, this.votes = const[]});

  final String name;

  final String? partnerId;

  final List<Vote> votes;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Vote {
  const Vote(this.nameId, this.value);

  final String nameId;
  final SwipeValue value;

  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);
  Map<String, dynamic> toJson() => _$VoteToJson(this);
}

enum SwipeValue {
  dislike,
  like;
}
