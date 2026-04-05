import 'package:json_annotation/json_annotation.dart';

part 'keyword_delete_response.g.dart';

@JsonSerializable()
class KeywordDeleteResponse {
  final bool success;
  final String message;

  KeywordDeleteResponse({required this.success, required this.message});

  factory KeywordDeleteResponse.fromJson(Map<String, dynamic> json) =>
      _$KeywordDeleteResponseFromJson(json);

  Map<String, dynamic> toJson() => _$KeywordDeleteResponseToJson(this);
}
