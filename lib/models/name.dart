import 'package:json_annotation/json_annotation.dart';

part 'name.g.dart';

@JsonSerializable()
class NameData {
  const NameData({required this.name, required this.gender, this.otherNames = const[]});

  final String name;
  final NameGender gender;

  final List<String> otherNames;

  factory NameData.fromJson(Map<String, dynamic> json) => _$NameDataFromJson(json);
  Map<String, dynamic> toJson() => _$NameDataToJson(this);
}

class Name extends NameData {
  const Name({required this.id, required super.name, required super.gender, super.otherNames});
  Name.fromBase({required this.id, required NameData nameBase})
      : super(name: nameBase.name, gender: nameBase.gender, otherNames: nameBase.otherNames);

  final String id;    // TODO remove this class, use a getter to normalize name to get id instead
}

enum NameGender {
  male,
  female,
  unisex,
}
