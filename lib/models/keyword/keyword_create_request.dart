import 'package:json_annotation/json_annotation.dart';

part 'keyword_create_request.g.dart';

@JsonSerializable()
class KeywordCreateRequest {
  final String keyword;

  KeywordCreateRequest({required this.keyword});

  factory KeywordCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$KeywordCreateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$KeywordCreateRequestToJson(this);
}
