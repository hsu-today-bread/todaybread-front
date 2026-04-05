import 'package:json_annotation/json_annotation.dart';

part 'keyword_create_response.g.dart';

@JsonSerializable()
class KeywordCreateResponse {
  final bool success;

  KeywordCreateResponse({required this.success});

  factory KeywordCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$KeywordCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$KeywordCreateResponseToJson(this);
}
