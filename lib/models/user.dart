import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pasteque_match/utils/_utils.dart';

part 'user.g.dart';

typedef UserVotes = Map<String, UserVote>;
typedef NameOrderIndexes = Map<String, double>;

class User extends UserData {
  const User({required this.id, required super.name, super.fcmToken, super.partnerId, super.votes});
  User.fromBase({required this.id, required UserData userData}): super(name: userData.name, fcmToken: userData.fcmToken, partnerId: userData.partnerId, votes: userData.votes, nameOrderIndexes: userData.nameOrderIndexes);
  factory User.fromJson(String id, JsonObject json) => User.fromBase(id: id, userData: _$UserDataFromJson(json));

  final String id;
}

@JsonSerializable()
class UserData {
  const UserData({required this.name, this.fcmToken, this.partnerId, this.votes = const{}, this.nameOrderIndexes = const {}, this.hiddenNames = const {}});
  factory UserData.fromJson(JsonObject json) => _$UserDataFromJson(json);

  /// User name
  final String name;

  /// User's FCM token
  final String? fcmToken;

  /// Id of the user's partner, if any
  final String? partnerId;

  /// Whether user has a partner or not
  bool get hasPartner => partnerId != null;

  /// Map of votes `<Name.id, UserVote>`
  /// Using a map ensure vote uniqueness
  final UserVotes votes;

  /// Map of order indexes of names `<Name.id, order index>`
  /// When user change the order of names manually, related indexes are stored here
  @JsonKey(name: 'orders')
  final NameOrderIndexes nameOrderIndexes;

  /// Set of hidden name IDs
  @JsonKey(name: 'hidden')
  final Set<String> hiddenNames;

  /// Return all likes
  /// (votes with SwipeValue.like value)
  /// OPTI use basic caching ?
  Iterable<String> get likes => votes.entries.where((entry) => entry.value.value.isLike).map((entry) => entry.key);
  JsonObject toJson() => _$UserDataToJson(this);
}

@JsonSerializable()
class UserVote {
  const UserVote(this.value, this.date);
  factory UserVote.fromJson(JsonObject json) => _$UserVoteFromJson(json);

  final SwipeValue value;
  final DateTime date;

  JsonObject toJson() => _$UserVoteToJson(this);
}

enum SwipeValue {
  dislike(FontAwesomeIcons.solidThumbsDown, Colors.red),
  superLike(FontAwesomeIcons.medal, Colors.yellow),
  like(FontAwesomeIcons.solidThumbsUp, Colors.green);

  const SwipeValue(this.icon, this.color);

  final IconData icon;
  final Color color;

  bool get isLike => this == SwipeValue.like || this == SwipeValue.superLike;
}

enum VoteSortType {
  name('Alphabétique'),
  date('Date de vote');

  const VoteSortType(this.label);

  final String label;
}
