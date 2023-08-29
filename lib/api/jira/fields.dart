import 'package:json_annotation/json_annotation.dart';

part 'fields.g.dart';

@JsonSerializable()
class Fields {
  String summary;

  Fields(this.summary);

  factory Fields.fromJson(Map<String, dynamic> json) =>
      _$FieldsFromJson(json);

  Map<String, dynamic> toJson() => _$FieldsToJson(
    this,
  );
}
