import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pasteque_match/utils/_utils.dart';

part 'user.g.dart';

typedef UserVotes = Map<String, UserVote>;

class User extends UserData {
  const User({required this.id, required super.name, super.partnerId, super.votes});
  User.fromBase({required this.id, required UserData userData}): super(name: userData.name, partnerId: userData.partnerId, votes: userData.votes);

  final String id;

  factory User.fromJson(String id, JsonObject json) => User.fromBase(id: id, userData: _$UserDataFromJson(json));
}

@JsonSerializable()
class UserData {
  const UserData({required this.name, this.partnerId, this.votes = const{}});

  /// User name
  final String name;

  /// Id of the user's partner, if any
  final String? partnerId;

  /// Whether user has a partner or not
  bool get hasPartner => partnerId != null;

  /// Map of votes
  /// <Name.id, SwipeValue>
  /// Using a map assure vote uniqueness
  final UserVotes votes;

  /// Return all likes
  /// (votes with SwipeValue.like value)
  List<String> get likes => votes.entries.where((entry) => entry.value.value == SwipeValue.like).map((entry) => entry.key).toList(growable: false);

  factory UserData.fromJson(JsonObject json) => _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

@JsonSerializable()
class UserVote {
  const UserVote(this.value, this.date);

  final SwipeValue value;
  final DateTime date;

  factory UserVote.fromJson(JsonObject json) => _$UserVoteFromJson(json);
  JsonObject toJson() => _$UserVoteToJson(this);
}

enum SwipeValue {
  dislike(Icons.thumb_down, Colors.red),
  like(Icons.thumb_up, Colors.green);

  const SwipeValue(this.icon, this.color);

  final IconData icon;
  final Color color;
}
