import 'package:json_annotation/json_annotation.dart';

part 'name.g.dart';

@JsonSerializable()
class Name {
  const Name({required this.name, required this.gender});

  final String name;
  final NameGender gender;

  factory Name.fromJson(Map<String, dynamic> json) => _$NameFromJson(json);
  Map<String, dynamic> toJson() => _$NameToJson(this);
}

enum NameGender {
  male,
  female,
  unisex,
}
