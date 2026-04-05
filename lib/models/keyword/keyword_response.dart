import 'package:json_annotation/json_annotation.dart';

part 'keyword_response.g.dart';

@JsonSerializable()
class KeywordResponse {
  final int userKeywordId;
  final String displayText;

  KeywordResponse({required this.userKeywordId, required this.displayText});

  factory KeywordResponse.fromJson(Map<String, dynamic> json) =>
      _$KeywordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$KeywordResponseToJson(this);
}
